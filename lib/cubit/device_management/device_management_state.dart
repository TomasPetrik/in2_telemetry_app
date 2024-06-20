import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/device_model.dart';

part 'device_management_state.freezed.dart';

@freezed
class DeviceManagementState with _$DeviceManagementState {
  const factory DeviceManagementState({
    List<DeviceModel>? assignedDevices,
    List<DeviceModel>? personalDevices,
    bool? supportDeviceMeasurement,
    bool? hasMeasurementTabs,
    MeasurementType? selectedMeasurementType,
    Set<MeasurementType>? allMeasurementTypes,
  }) = _DeviceManagementState;
}
