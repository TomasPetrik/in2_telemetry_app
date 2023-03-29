import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';

part 'device_management_state.freezed.dart';

@freezed
class DeviceManagementState with _$DeviceManagementState {
  const factory DeviceManagementState({
    List<Device>? devices,
    bool? supportDeviceMeasurement,
    bool? hasMeasurementTabs,
    MeasurementType? selectedMeasurementType,
    Set<MeasurementType>? allMeasurementTypes,
  }) = _DeviceManagementState;
}
