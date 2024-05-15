import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_setting_contract.dart';
import 'package:scalesoft_app/api/contracts/user/user_contract.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/data/providers/settings_db_provider.dart';
import 'package:scalesoft_app/data/providers/user_db_provider.dart';
import 'package:scalesoft_app/managers/background_measurement_manager.dart';
import 'package:scalesoft_app/model/enum/user_problem_type.dart';
import 'package:scalesoft_app/no_users_exception.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/report_service.dart';

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

  final Stream<List<UserModel>> _allUsersStream;

  UserCubit._(this._userDbProvider, this._allUsersStream, UserCubitState initialState) : super(initialState) {
    _allUsersStream.listen((users) {
      var activeUserId = state._userId;
      if (users.none((x) => x.id == activeUserId)) {
        activeUserId = maxBy(users, (x) => x.lastActive)?.id;

        if (activeUserId != null) {
          _userDbProvider.updateUser(activeUserId, UsersCompanion(lastActive: Value(DateTime.now())));
        }
      }

      emit(UserCubitState(activeUserId, users, state.aggregateAllUsers));
    });
  }

  @factoryMethod
  static Future<UserCubit> create(
    UserDbProvider userDbProvider,
    SettingsDbProvider settingsDbProvider,
  ) async {
    final usersStream = userDbProvider.getAllRootUsers().asBroadcastStream();

    final initialUsers = await usersStream.first;

    final initialUserId = maxBy(initialUsers, (x) => x.lastActive)?.id;

    final settings = await settingsDbProvider.getSettings();

    final state = UserCubitState(initialUserId, initialUsers, settings.showAllUsers);

    return UserCubit._(userDbProvider, usersStream, state);
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

    if (!state.allUsers.any((x) => x.id == userId)) {
      await _allUsersStream.firstWhere((list) => list.any((user) => user.id == userId)).timeout(
            const Duration(seconds: 5),
          );
    }

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

  Future<List<CarePlan>> getActiveCarePlans() async {
    List<CarePlan> carePlans = [];
    for (final userAccount in state.rootUsers) {
      // for (final CarePlanContract carePlan in userAccount.carePlans!) {
      //   if (carePlan.isActiveToday()) {
      //     carePlans.add(carePlan);
      //   }
      // }
    }

    return carePlans;
  }

  Future<List<CarePlan>> getAllCarePlans() async {
    // return getSessionAccounts().fold<List<CarePlanContract>>(
    //   [],
    //   (prevCarePlans, userAccount) => [...prevCarePlans, ...userAccount.carePlans ?? []],
    // ); TODO

    return [];
  }

  Future<List<Measurement>> getPendingResults() async {
    List<Measurement> pendingResults = [];
    for (final userAccount in state.rootUsers) {
      // final userPendingResults = _pendingResultsDbProvider.getPerUser(userAccount.user.muid);
      // if (userPendingResults.isNotEmpty == true) {
      //   pendingResults.addAll(userPendingResults);
      // } TODO
    }

    return pendingResults;
  }

  List<Measurement> getOfflineResults() {
    return [];
    // TODO
    // final offlineResults = getPendingResults();
    //
    // if (offlineResults.isEmpty) return null;
    //
    // final List<MeasurementDataContract> offlineResultsConverted =
    //     MeasurementHelper.getOfflineResultsConverted(
    //   offlineResults,
    //   null,
    //   null,
    // );
    //
    // offlineResultsConverted.sort(
    //   (a, b) => b.measurementDateTime.millisecondsSinceEpoch
    //       .compareTo(a.measurementDateTime.millisecondsSinceEpoch),
    // );
    //
    // return offlineResultsConverted;
  }

  Future<SyncState> detectSyncState() async {
    List<UserModel> userAccounts = state.rootUsers;

    //1. check if any user session was expired
    final expiredAccount = userAccounts.firstWhereOrNull((userAccount) => userAccount.isSessionExpired);

    if (expiredAccount != null) {
      return SyncState.userSessionExpired(expiredAccount);
    }

    final offlineResults = getOfflineResults();

    //2. check if user data sync failed
    final someUserSessionExpired = userAccounts.any((userAccount) => userAccount.lastSyncFailed == true);
    if (userAccounts.length == 1) {
      if (someUserSessionExpired) {
        // return SyncState.syncUserDataFailed(
        //   offlineResults,
        //   userAccounts[0].lastSyncAt,
        // );
      }
    } else if (someUserSessionExpired) {
      // return SyncState.syncSomeUsersDataFailed(
      //   offlineResults,
      // ); TODO
    }

    //3. check if user results sync failed
    // if (userAccounts.length == 1) {
    // if (offlineResults?.isNotEmpty == true) {
    //   return SyncState.userResultsFailed(
    //     offlineResults,
    //     userAccounts[0].lastSyncAt,
    //   );
    // }
    // } else if (offlineResults?.isNotEmpty == true) {
    //   return SyncState.someUsersResultsFailed(
    //     offlineResults,
    //   );
    // } TODO

    //4. check if user plan was updated
    final List<CarePlan> changedCarePlans = [];
    for (final userAccount in userAccounts) {
      // final changedUserPlans = userAccount.carePlans!.where((carePlan) => carePlan.wasChanged == true);
      // changedCarePlans.addAll(changedUserPlans); TODO
    }

    final someCarePlansChanged = changedCarePlans.isNotEmpty;
    if (userAccounts.length == 1 && someCarePlansChanged) {
      return SyncState.userCarePlanChanged(changedCarePlans[0]);
    } else if (someCarePlansChanged) {
      // TODO: ChangedCarePlans should be entities? Or probably rewrite most of this
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

  Future<UserProblemType?> getProblemIfExists(UserModel user) async {
    if (user.isSessionExpired) {
      return UserProblemType.sessionExpired;
    }

    if (user.lastSyncFailed) {
      return UserProblemType.lastSyncFailed;
    }
    // TODO
    // if (carePlans?.any((carePlan) => carePlan.wasChanged == true) == true) {
    //   return UserProblemType.carePlanUpdated;
    // }

    // TODO
    // final pendingResults = _pendingResultsDbProvider.getPerUser(user.user.muid);
    // if (pendingResults.isNotEmpty == true) {
    //   return UserProblemType.syncResultsFailed;
    // }
    return null;
  }
}
