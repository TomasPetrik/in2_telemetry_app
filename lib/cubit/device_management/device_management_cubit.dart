import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/cubit/device_management/device_management_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/utils/constants.dart';

@injectable
class DeviceManagementCubit extends Cubit<DeviceManagementState> {
  final AccountDbProvider _accountDbProvider;
  final PairedDevicesDbProvider _pairedDevicesDbProvider;
  late UserAccount userAccount;

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
          (device) =>
              device.supportedMeasurementTypes!.contains(
                measurementType,
              ) &&
              (userAccount.canMeasureWithUnknowDevice ||
                  (!userAccount.canMeasureWithUnknowDevice &&
                      userAccount.canMeasureWithDeviceId(device.macAddress!))),
        )
        .toList();
  }

  DeviceManagementCubit(
    this._accountDbProvider,
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
    String userId,
  ) {
    userAccount = _accountDbProvider.get(userId)!;
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
