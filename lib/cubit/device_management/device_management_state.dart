import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';

part 'device_management_state.freezed.dart';

@freezed
class DeviceManagementState with _$DeviceManagementState {
  const factory DeviceManagementState({
    List<Device>? assignedDevices,
    List<Device>? personalDevices,
    bool? supportDeviceMeasurement,
    bool? hasMeasurementTabs,
    MeasurementTypeContract? selectedMeasurementType,
    Set<MeasurementTypeContract>? allMeasurementTypes,
  }) = _DeviceManagementState;
}
