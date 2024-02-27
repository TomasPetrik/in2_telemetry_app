import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';

part 'sync_event.freezed.dart';

@freezed
class SyncEvent with _$SyncEvent {
  const factory SyncEvent.init() = _Init;
  const factory SyncEvent.syncAll() = _SyncAll;
  const factory SyncEvent.syncResults() = _SyncResults;
  factory SyncEvent.userSessionExpired(String refreshToken) = _UserExpired;
  factory SyncEvent.resolveUpdatedUserPlan(
    CarePlanContract carePlan,
  ) = _ResolveUpdatedPlan;
  factory SyncEvent.removeOfflineResult(MeasurementDataContract measurementResult) =
      _RemoveOfflineResult;
}
