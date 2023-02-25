import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/model/user_account.dart';

part 'sync_state.freezed.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState.none() = _None;
  const factory SyncState.inProgress() = _InProgress;
  const factory SyncState.synced() = _Synced;
  factory SyncState.userSessionExpired(UserAccount userAccount) =
      _SingleUserExpired;
  factory SyncState.syncUserDataFailed(
    List<MeasurementResult>? offlinResults,
    DateTime? lastSyncAt,
  ) = _SyncUserDataFailed;
  const factory SyncState.syncSomeUsersDataFailed(
    List<MeasurementResult>? offlinResults,
  ) = _SyncSomeUsersDataFailed;
  const factory SyncState.userResultsFailed(
    List<MeasurementResult>? offlineResults,
    DateTime? lastSyncAt,
  ) = _UserResultsFailed;
  const factory SyncState.someUsersResultsFailed(
    List<MeasurementResult>? offlinResults,
  ) = _SomeUsersResultsFailed;
  const factory SyncState.userCarePlanChanged(CarePlan carePlan) =
      _UserCarePlanChanged;
  const factory SyncState.someUsersCarePlanChanged(
    UserAccount userAccount,
    CarePlan carePlan,
  ) = _SomeUsersCarePlanChanged;
}
