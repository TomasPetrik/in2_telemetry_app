import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/managers/background_measurement_manager.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

@singleton
class Session {
  final AccountDbProvider _accountDbProvider;
  final PendingResultsDbProvider _pendingResultsDbProvider;

  AuthToken? token;
  List<String> userPermissions = [];
  Hospital? hospital;
  UserAccount? userAccount;
  bool? isMultiUser;

  //For history and future details restoration
  List<UserEvaluationDay>? usersEvaluationsDayRestoration;
  //For calendar restoration
  DateTime? preSelectedDtRestoration;
  Session(this._accountDbProvider, this._pendingResultsDbProvider);

  bool supportMultiUser() {
    return _accountDbProvider.getAll().length > 1;
  }

  DateTime? getLastSyncAt() {
    List<DateTime> lastSyncAtItems = [];
    for (final userAccount in getSessionAccounts()) {
      if (userAccount.lastSyncAt != null) {
        lastSyncAtItems.add(userAccount.lastSyncAt!);
      }
    }

    lastSyncAtItems.sort(
      (a, b) => a.millisecondsSinceEpoch.compareTo(b.millisecondsSinceEpoch),
    );

    return lastSyncAtItems.isEmpty ? null : lastSyncAtItems.last;
  }

  List<UserAccount> getSessionAccounts() {
    if (isMultiUser == true) {
      return _accountDbProvider.getAll().toList();
    } else {
      return [if (userAccount != null) userAccount!];
    }
  }

  List<CarePlanContract> getActiveCarePlans() {
    List<CarePlanContract> carePlans = [];
    for (final userAccount in getSessionAccounts()) {
      for (final CarePlanContract carePlan in userAccount.carePlans!) {
        if (carePlan.isActiveToday()) {
          carePlans.add(carePlan);
        }
      }
    }

    return carePlans;
  }

  List<CarePlanContract> getAllCarePlans() {
    return getSessionAccounts().fold<List<CarePlanContract>>(
      [],
      (prevCarePlans, userAccount) =>
          [...prevCarePlans, ...userAccount.carePlans ?? []],
    );
  }

  List<Measurement> getPendingResults() {
    List<Measurement> pendingResults = [];
    for (final userAccount in getSessionAccounts()) {
      final userPendingResults =
          _pendingResultsDbProvider.getPerUser(userAccount.user.muid);
      if (userPendingResults.isNotEmpty == true) {
        pendingResults.addAll(userPendingResults);
      }
    }

    return pendingResults;
  }

  List<MeasurementDataContract>? getOfflineResults() {
    final offlineResults = getPendingResults();

    if (offlineResults.isEmpty) return null;

    final List<MeasurementDataContract> offlineResultsConverted =
        MeasurementHelper.getOffilneResultsConverted(
      offlineResults,
      null,
      null,
    );

    offlineResultsConverted.sort(
      (a, b) => b.measurementDateTime.millisecondsSinceEpoch
          .compareTo(a.measurementDateTime.millisecondsSinceEpoch),
    );

    return offlineResultsConverted;
  }

  Future<SyncState> detectSyncState() async {
    List<UserAccount> userAccounts = getSessionAccounts();

    //1. check if any user session was expired
    final expiredAccount = userAccounts
        .firstWhereOrNull((userAccount) => userAccount.sessionExpired == true);

    if (expiredAccount != null) {
      return SyncState.userSessionExpired(expiredAccount);
    }

    List<MeasurementDataContract>? offlineResults = getOfflineResults();

    //2. check if user data sync failed
    final someUserSessionExpired =
        userAccounts.any((userAccount) => userAccount.lastSyncFailed == true);
    if (userAccounts.length == 1) {
      if (someUserSessionExpired) {
        return SyncState.syncUserDataFailed(
          offlineResults,
          userAccounts[0].lastSyncAt,
        );
      }
    } else if (someUserSessionExpired) {
      return SyncState.syncSomeUsersDataFailed(
        offlineResults,
      );
    }

    //3. check if user results sync failed
    if (userAccounts.length == 1) {
      if (offlineResults?.isNotEmpty == true) {
        return SyncState.userResultsFailed(
          offlineResults,
          userAccounts[0].lastSyncAt,
        );
      }
    } else if (offlineResults?.isNotEmpty == true) {
      return SyncState.someUsersResultsFailed(
        offlineResults,
      );
    }

    //4. check if user plan was updated
    final List<CarePlanContract> changedCarePlans = [];
    for (final userAccount in userAccounts) {
      final changedUserPlans = userAccount.carePlans!
          .where((carePlan) => carePlan.wasChanged == true);
      changedCarePlans.addAll(changedUserPlans);
    }

    final someCarePlansChanged = changedCarePlans.isNotEmpty;
    if (userAccounts.length == 1 && someCarePlansChanged) {
      return SyncState.userCarePlanChanged(changedCarePlans[0]);
    } else if (someCarePlansChanged) {
      final userAccount = _accountDbProvider.get(changedCarePlans[0].userId!)!;
      return SyncState.someUsersCarePlanChanged(
        userAccount,
        changedCarePlans[0],
      );
    }

    if(await (getIt<BackgroundMeasurementManager>().isSetupRequired())){
      return const SyncState.newWatchAssigned();
    }

    return const SyncState.synced();
  }

  UserProblemType? getProblemIfExists(UserAccount userAccount) {
    final userProblem = userAccount.getProblemIfExists();
    if (userProblem != null) {
      return userProblem;
    }

    final pendingResults =
        _pendingResultsDbProvider.getPerUser(userAccount.user.muid);
    if (pendingResults.isNotEmpty == true) {
      return UserProblemType.syncResultsFailed;
    }
    return null;
  }
}
