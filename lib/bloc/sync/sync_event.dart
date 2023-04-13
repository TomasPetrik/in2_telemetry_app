import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';

part 'sync_event.freezed.dart';

@freezed
class SyncEvent with _$SyncEvent {
  const factory SyncEvent.init() = _Init;
  const factory SyncEvent.syncAll() = _SyncAll;
  const factory SyncEvent.syncResults() = _SyncResults;
  factory SyncEvent.userSessionExpired(String refreshToken) = _UserExpired;
  factory SyncEvent.resolveUpdatedUserPlan(
    CarePlan carePlan,
  ) = _ResolveUpdatedPlan;
  factory SyncEvent.removeOfflineResult(MeasurementResult measurementResult) =
      _RemoveOfflineResult;
}
