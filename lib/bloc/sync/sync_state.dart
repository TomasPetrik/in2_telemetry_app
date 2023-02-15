import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/model/user_account.dart';

part 'sync_state.freezed.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState.none() = _None;
  const factory SyncState.inProgress() = _InProgress;
  const factory SyncState.synced() = _Synced;
  factory SyncState.userSessionExpired(UserAccount userAccount) =
      _SingleUserExpired;
  const factory SyncState.syncUserDataFailed(DateTime? lastSyncAt) =
      _SyncUserDataFailed;
  const factory SyncState.syncSomeUsersDataFailed() = _SyncSomeUsersDataFailed;
  const factory SyncState.userResultsFailed(
    List<Measurement> pendingResults,
    DateTime? lastSyncAt,
  ) = _UserResultsFailed;
  const factory SyncState.someUsersResultsFailed(
    List<Measurement> pendingResults,
  ) = _SomeUsersResultsFailed;
  const factory SyncState.userCarePlanChanged(CarePlan carePlan) =
      _UserCarePlanChanged;
  const factory SyncState.someUsersCarePlanChanged(
    UserAccount userAccount,
    CarePlan carePlan,
  ) = _SomeUsersCarePlanChanged;
}
