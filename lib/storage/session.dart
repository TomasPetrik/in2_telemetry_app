import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/bloc/sync/sync_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';

@singleton
class Session {
  AuthToken? token;
  List<UserPermission>? userPermissions;
  Hospital? hospital;
  UserAccount? userAccount;
  bool? isMultiUser;
  final AccountDbProvider _accountDbProvider;

  final PendingResultsDbProvider _pendingResultsDbProvider;

  Session(this._accountDbProvider, this._pendingResultsDbProvider);

  List<UserAccount> getCurrentUsers() {
    if (isMultiUser == true) {
      return _accountDbProvider.getAll().toList();
    } else {
      return [if (userAccount != null) userAccount!];
    }
  }

  SyncState detectSyncState() {
    List<UserAccount> userAccounts = getCurrentUsers();

    //1. check if any user session was expired
    final expiredAccount = userAccounts
        .firstWhereOrNull((userAccount) => userAccount.sessionExpired == true);

    if (expiredAccount != null) {
      return SyncState.userSessionExpired(expiredAccount);
    }

    //2. check if user data sync failed
    final someUserSessionExpired =
        userAccounts.any((userAccount) => userAccount.lastSyncFailed == true);
    if (userAccounts.length == 1) {
      if (someUserSessionExpired) {
        return SyncState.syncUserDataFailed(userAccounts[0].lastSyncAt);
      }
    } else if (someUserSessionExpired) {
      return const SyncState.syncSomeUsersDataFailed();
    }

    //3. check if user results sync failed
    List<Measurement> pendingResults = _pendingResultsDbProvider.getAll();
    if (userAccounts.length == 1) {
      final userPendingResults = pendingResults
          .where(
            (pendingResult) =>
                pendingResult.patientMuid == userAccounts[0].user.muid,
          )
          .toList();
      if (userPendingResults.isNotEmpty) {
        return SyncState.userResultsFailed(
          userPendingResults,
          userAccounts[0].lastSyncAt,
        );
      }
    } else if (pendingResults.isNotEmpty == true) {
      return SyncState.someUsersResultsFailed(pendingResults);
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

  bool userHasProblem(UserAccount userAccount) {
    if (userAccount.hasProblem()) {
      return true;
    }

    final pendingResults =
        _pendingResultsDbProvider.getPerUser(userAccount.user.muid);
    if (pendingResults?.isNotEmpty == true) {
      return true;
    }
    return false;
  }
}
