import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';

part 'sync_event.freezed.dart';

@freezed
class SyncEvent with _$SyncEvent {
  const factory SyncEvent.init() = _Init;
  const factory SyncEvent.syncAll() = _SyncAll;
  const factory SyncEvent.syncResults() = _SyncResults;
  factory SyncEvent.userSessionExpired(String refreshToken) = _UserExpired;
  factory SyncEvent.resolveUpdatedUserPlan(
    int carePlanId,
  ) = _ResolveUpdatedPlan;
  factory SyncEvent.removeOfflineResult(MeasurementDataContract measurementResult) =
      _RemoveOfflineResult;
}
