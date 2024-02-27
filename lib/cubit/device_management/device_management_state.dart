import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_contract.dart';

part 'device_management_state.freezed.dart';

@freezed
class DeviceManagementState with _$DeviceManagementState {
  const factory DeviceManagementState({
    List<SourceDeviceContract>? assignedDevices,
    List<SourceDeviceContract>? personalDevices,
    bool? supportDeviceMeasurement,
    bool? hasMeasurementTabs,
    MeasurementTypeContract? selectedMeasurementType,
    Set<MeasurementTypeContract>? allMeasurementTypes,
  }) = _DeviceManagementState;
}
