import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/cubit/device_management/device_management_state.dart';
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/utils/constants.dart';

@injectable
class DeviceManagementCubit extends Cubit<DeviceManagementState> {
  final PairedDevicesDbProvider _pairedDevicesDbProvider;

  bool supportedDeviceMeasurement(MeasurementType measurementType) {
    return Constants.supportedDevices.any(
      (device) => device.supportedMeasurementTypes!.contains(
        measurementType,
      ),
    );
  }

  List<Device> getSuitableDevices(MeasurementType measurementType) {
    return _pairedDevicesDbProvider.box.values
        .where(
          (device) => device.supportedMeasurementTypes!.contains(
            measurementType,
          ),
        )
        .toList();
  }

  DeviceManagementCubit(
    this._pairedDevicesDbProvider,
  ) : super(
          const DeviceManagementState(
            devices: null,
            supportDeviceMeasurement: null,
          ),
        );

  void init(
    MeasurementType measurementType,
    Set<MeasurementType>? allMeasurementTypes,
  ) {
    final supportDeviceMeasurement =
        supportedDeviceMeasurement(measurementType);
    final suitableDevices = getSuitableDevices(measurementType);
    final hasMeasurementTabs =
        allMeasurementTypes != null && allMeasurementTypes.length > 1;

    emit(
      DeviceManagementState(
        selectedMeasurementType: measurementType,
        supportDeviceMeasurement: supportDeviceMeasurement,
        devices: suitableDevices,
        hasMeasurementTabs: hasMeasurementTabs,
        allMeasurementTypes: allMeasurementTypes,
      ),
    );
  }

  void selectMeasurementType(MeasurementType measurementType) {
    final supportDeviceMeasurement =
        supportedDeviceMeasurement(measurementType);
    final suitableDevices = getSuitableDevices(measurementType);

    emit(
      state.copyWith(
        selectedMeasurementType: measurementType,
        supportDeviceMeasurement: supportDeviceMeasurement,
        devices: suitableDevices,
      ),
    );
  }

  void removeDevice(Device device, MeasurementType measurementType) async {
    await _pairedDevicesDbProvider.remove(device);
    final suitableDevices = getSuitableDevices(measurementType);

    emit(state.copyWith(devices: suitableDevices));
  }
}
