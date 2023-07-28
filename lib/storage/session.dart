import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/auth_token.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

@singleton
class Session {
  AuthToken? token;
  List<UserPermission>? userPermissions;
  Hospital? hospital;
  UserAccount? userAccount;
  bool? isMultiUser;
  final AccountDbProvider _accountDbProvider;

  //For history and future details restoration
  List<UserEvaluationDay>? usersEvaluationsDayRestoration;
  //For calendar restoration
  DateTime? preSelectedDtRestoration;

  final PendingResultsDbProvider _pendingResultsDbProvider;

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

  List<CarePlan> getActiveCarePlans() {
    List<CarePlan> carePlans = [];
    for (final userAccount in getSessionAccounts()) {
      for (final CarePlan carePlan in userAccount.carePlans!) {
        if (carePlan.isActiveToday()) {
          carePlans.add(carePlan);
        }
      }
    }

    return carePlans;
  }

  List<CarePlan> getAllCarePlans() {
    return getSessionAccounts().fold<List<CarePlan>>(
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

  List<MeasurementResult>? getOfflineResults() {
    final offlineResults = getPendingResults();

    if (offlineResults.isEmpty) return null;

    final List<MeasurementResult> offlineResultsConverted =
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

  SyncState detectSyncState() {
    List<UserAccount> userAccounts = getSessionAccounts();

    //1. check if any user session was expired
    final expiredAccount = userAccounts
        .firstWhereOrNull((userAccount) => userAccount.sessionExpired == true);

    if (expiredAccount != null) {
      return SyncState.userSessionExpired(expiredAccount);
    }

    List<MeasurementResult>? offlineResults = getOfflineResults();

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
    final List<CarePlan> changedCarePlans = [];
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
