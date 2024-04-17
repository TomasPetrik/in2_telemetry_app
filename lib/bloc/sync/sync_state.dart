import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/data/app_database.dart';

part 'sync_state.freezed.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState.none() = _None;
  const factory SyncState.inProgress() = _InProgress;
  const factory SyncState.synced() = _Synced;
  factory SyncState.userSessionExpired(UserModel userAccount) =
      _SingleUserExpired;
  factory SyncState.syncUserDataFailed(
    List<MeasurementDataContract>? offlinResults,
    DateTime? lastSyncAt,
  ) = _SyncUserDataFailed;
  const factory SyncState.syncSomeUsersDataFailed(
    List<MeasurementDataContract>? offlinResults,
  ) = _SyncSomeUsersDataFailed;
  const factory SyncState.userResultsFailed(
    List<MeasurementDataContract>? offlineResults,
    DateTime? lastSyncAt,
  ) = _UserResultsFailed;
  const factory SyncState.someUsersResultsFailed(
    List<MeasurementDataContract>? offlinResults,
  ) = _SomeUsersResultsFailed;
  const factory SyncState.userCarePlanChanged(CarePlan carePlan) =
      _UserCarePlanChanged;
  const factory SyncState.someUsersCarePlanChanged(
    UserModel userAccount,
    CarePlan carePlan,
  ) = _SomeUsersCarePlanChanged;
  const factory SyncState.newWatchAssigned() = _NewWatchAssigned;
}
