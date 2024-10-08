import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_setting_contract.dart';
import 'package:scalesoft_app/api/contracts/user/user_contract.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/data/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/data/providers/settings_db_provider.dart';
import 'package:scalesoft_app/data/providers/user_db_provider.dart';
import 'package:scalesoft_app/managers/background_measurement_manager.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/no_users_exception.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';

class UserCubitState {
  final int? _userId;
  final List<UserModel> rootUsers;
  final bool aggregateAllUsers;

  const UserCubitState(this._userId, this.rootUsers, this.aggregateAllUsers);

  Iterable<UserModel> get allUsers => [...rootUsers, ...rootUsers.expand((x) => x.representedPeople)];

  int get currentUserId {
    if (_userId == null) {
      throw const NoUsersException();
    }
    return _userId!;
  }

  UserModel get currentUser {
    if (rootUsers.isEmpty) {
      throw const NoUsersException();
    }

    final result = allUsers.firstWhereOrNull((x) => x.id == currentUserId);

    if (result == null) {
      final logMessage = "Current user ID is $currentUserId, but no such user was found.";

      debugPrint(logMessage);
      getIt<ReportService>().trackEvent(severity: LogSeverity.error, message: logMessage);
      return rootUsers.first;
    }

    return result;
  }
}

@preResolve
@lazySingleton
class UserCubit extends Cubit<UserCubitState> {
  final UserDbProvider _userDbProvider;
  final MeasurementsDbProvider _measurementsDbProvider;
  final CarePlanDbProvider _carePlanDbProvider;

  final Stream<List<UserModel>> _allUsersStream;

  UserCubit._(
    this._userDbProvider,
    this._allUsersStream,
    this._measurementsDbProvider,
    this._carePlanDbProvider,
    UserCubitState initialState,
  ) : super(initialState) {
    _allUsersStream.listen((rootUsers) {
      var activeUserId = state._userId;

      final allUsers = [...rootUsers, ...rootUsers.expand((x) => x.representedPeople)];

      if (allUsers.none((x) => x.id == activeUserId)) {
        activeUserId = maxBy(allUsers.where((x)=>x.lastActive!=null), (x) => x.lastActive)?.id;

        activeUserId ??= rootUsers.firstOrNull?.id;

        if (activeUserId != null) {
          _userDbProvider.updateUser(activeUserId, UsersCompanion(lastActive: Value(DateTime.now())));
        }
      }

      emit(UserCubitState(activeUserId, rootUsers, state.aggregateAllUsers));
    });
  }

  @factoryMethod
  static Future<UserCubit> create(
    UserDbProvider userDbProvider,
    SettingsDbProvider settingsDbProvider,
    MeasurementsDbProvider measurementsDbProvider,
    CarePlanDbProvider carePlanDbProvider,
  ) async {
    final usersStream = userDbProvider.getAllRootUsers().asBroadcastStream();

    final initialUsers = await usersStream.first;

    final initialUserId = maxBy(initialUsers, (x) => x.lastActive)?.id;

    final settings = await settingsDbProvider.getSettings();

    final state = UserCubitState(initialUserId, initialUsers, settings.showAllUsers);

    return UserCubit._(
      userDbProvider,
      usersStream,
      measurementsDbProvider,
      carePlanDbProvider,
      state,
    );
  }

  Future<void> setActiveUser(int userId) async {
    emit(UserCubitState(userId, state.rootUsers, state.aggregateAllUsers));
    await _userDbProvider.updateUser(userId, UsersCompanion(lastActive: Value(DateTime.now())));
  }

  Future<int> createOrUpdateUser(
    UserContract rootUser,
    List<UserContract>? representedPeople,
    int hospitalId,
    AuthToken authToken,
    List<String> permissions,
    List<TimeSettingContract> timeSettingContracts,
  ) async {
    final userId = await _userDbProvider.createOrUpdateUser(
      rootUser,
      representedPeople,
      hospitalId,
      authToken,
      permissions,
      timeSettingContracts,
    );

    await waitForChange((x)=>x.id == userId);

    return userId;
  }

  Future deleteUser(int userId) async {
    await _userDbProvider.remove(userId);

    await _allUsersStream.firstWhere((list) => list.none((user) => user.id == userId)).timeout(
          const Duration(seconds: 5),
        );
  }

  void toggleAllUserAggregation(bool newValue) {
    emit(UserCubitState(state._userId, state.rootUsers, newValue));
  }

  //For calendar restoration
  DateTime? preSelectedDtRestoration;

  Future<List<Measurement>> getPendingResults() async {
    final userIds = state.allUsers.map((x) => x.id);

    final pendingResults = await _measurementsDbProvider.getByUsers(userIds, isUploaded: false);

    return pendingResults;
  }

  Future<List<MeasurementResultViewModel>> getOfflineResults() async {
    final offlineResults = await getPendingResults();

    final users = state.allUsers;

    final viewModels = offlineResults.map(
      (x) => MeasurementResultViewModel(
        x.measurementType,
        x.measuredAt,
        users.firstWhere((user) => user.id == x.userId),
        1,
        1,
        null,
      ),
    );

    return viewModels.sortedBy((x) => x.measurementTime);
  }

  Future<SyncState> detectSyncState() async {
    List<UserModel> userAccounts = state.rootUsers;

    //1. check if any user session was expired
    final expiredAccount = userAccounts.firstWhereOrNull((userAccount) => userAccount.isSessionExpired);

    if (expiredAccount != null) {
      return SyncState.userSessionExpired(expiredAccount);
    }

    final offlineResults = await getOfflineResults();

    //2. check if user data sync failed
    final someUserSessionExpired = userAccounts.any((userAccount) => userAccount.lastSyncFailed);
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
    if (offlineResults.isNotEmpty) {
      if (userAccounts.length == 1) {
        return SyncState.userResultsFailed(offlineResults, userAccounts[0].lastSyncAt);
      }
      return SyncState.someUsersResultsFailed(offlineResults);
    }

    //4. check if user plan was updated
    final allUserIds = state.allUsers.map((x) => x.id);
    final changedCarePlans = await _carePlanDbProvider.getChangedPlans(allUserIds);

    final someCarePlansChanged = changedCarePlans.isNotEmpty;
    if (userAccounts.length == 1 && someCarePlansChanged) {
      return SyncState.userCarePlanChanged(changedCarePlans[0]);
    } else if (someCarePlansChanged) {
      final userAccount = state.rootUsers.firstWhereOrNull((x) => x.id == changedCarePlans[0].targetUserId);

      if (userAccount != null) {
        return SyncState.someUsersCarePlanChanged(
          userAccount,
          changedCarePlans[0],
        );
      }
    }

    if (await (getIt<BackgroundMeasurementManager>().isSetupRequired())) {
      return const SyncState.newWatchAssigned();
    }

    return const SyncState.synced();
  }

  /// Waits until a change is propagated, using the given [test] on [state.allUsers].
  /// If the change isn't detected in [timeout] seconds, a [TimeoutException] is thrown.
  Future<void> waitForChange(bool Function(UserModel user) test, {int timeout = 10}) async {
    if (!state.allUsers.any(test)) {
      await _allUsersStream.firstWhere((users) => users.any(test)).timeout(
            Duration(seconds: timeout),
          );
    }
  }

  UserModel getUser(int userId){
    return state.allUsers.firstWhere((x)=>x.id == userId);
  }
}
