import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/cubit/device_management/device_management_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';

@injectable
class DeviceManagementCubit extends Cubit<DeviceManagementState> {
  final AccountDbProvider _accountDbProvider;
  final PairedDevicesDbProvider _pairedDevicesDbProvider;
  late UserAccount userAccount;

  bool supportedDeviceMeasurement(MeasurementTypeContract measurementType) {
    return ConfigurationConstants.supportedDevices.any(
      (device) => device.supportedMeasurementTypes!.contains(
        measurementType,
      ),
    );
  }

  List<Device> getAssignedDevices(MeasurementTypeContract measurementType) {
    List<Device> prioritisedDevices = [];

    final allPairedDevices = _pairedDevicesDbProvider.box.values
        .where(
          (device) => device.supportedMeasurementTypes!.contains(
            measurementType,
          ),
        )
        .toList();

    //1. Add all user assigned devices with flag if was previously paired
    if (userAccount.assignedDevices?.isNotEmpty == true) {
      for (final assignedDevice in userAccount.assignedDevices!) {
        final suppDev = ConfigurationConstants.supportedDevices.firstWhereOrNull(
          (suppDev) =>
              suppDev.modelName == assignedDevice.modelName &&
              suppDev.deviceManufacturer == assignedDevice.deviceManufacturer,
        );

        if (suppDev == null) continue;

        bool wasPaired = allPairedDevices.any(
          (dev) =>
              dev.deviceIdentifier?.toLowerCase() ==
              assignedDevice.deviceIdentifier?.toLowerCase(),
        );
        prioritisedDevices.add(
          suppDev.copyWith(
            deviceIdentifier: assignedDevice.deviceIdentifier,
            assignedIdentifier: assignedDevice.assignedIdentifier,
            bluetoothAddress: assignedDevice.bluetoothAddress,
            wasPaired: wasPaired,
            isLendedDevice: true,
          ),
        );
      }
    }

    return prioritisedDevices;
  }

  //Personal devices which are not matching with user devices and user has also permission
  //for measurements with unknow devices <canMeasureWithUnknowDevice>
  List<Device> getPersonalDevices(MeasurementTypeContract measurementType) {
    final allPairedDevices = _pairedDevicesDbProvider.box.values
        .where(
          (device) => device.supportedMeasurementTypes!.contains(
            measurementType,
          ),
        )
        .toList();

    final assignedDevices = getAssignedDevices(measurementType);

    final List<String> userAssignedDevicesIds = assignedDevices
        .map((dev) => dev.deviceIdentifier!.toLowerCase())
        .toList();

    final personalDevices = allPairedDevices
        .where(
          (dev) =>
              userAccount.canMeasureWithUnknowDevice &&
              !userAssignedDevicesIds
                  .contains(dev.deviceIdentifier?.toLowerCase()),
        )
        .toList();

    return personalDevices;
  }

  DeviceManagementCubit(
    this._accountDbProvider,
    this._pairedDevicesDbProvider,
  ) : super(
          const DeviceManagementState(
            assignedDevices: null,
            personalDevices: null,
            supportDeviceMeasurement: null,
          ),
        );

  void init(
    MeasurementTypeContract measurementType,
    Set<MeasurementTypeContract>? allMeasurementTypes,
    String userId,
  ) {
    userAccount = _accountDbProvider.get(userId)!;
    final supportDeviceMeasurement =
        supportedDeviceMeasurement(measurementType);
    final assignedDevices = getAssignedDevices(measurementType);
    final personalDevices = getPersonalDevices(measurementType);
    final hasMeasurementTabs =
        allMeasurementTypes != null && allMeasurementTypes.length > 1;

    emit(
      DeviceManagementState(
        selectedMeasurementType: measurementType,
        supportDeviceMeasurement: supportDeviceMeasurement,
        assignedDevices: assignedDevices,
        personalDevices: personalDevices,
        hasMeasurementTabs: hasMeasurementTabs,
        allMeasurementTypes: allMeasurementTypes,
      ),
    );
  }

  void selectMeasurementType(MeasurementTypeContract measurementType) {
    final supportDeviceMeasurement =
        supportedDeviceMeasurement(measurementType);
    final assignedDevices = getAssignedDevices(measurementType);
    final personalDevices = getPersonalDevices(measurementType);

    emit(
      state.copyWith(
        selectedMeasurementType: measurementType,
        supportDeviceMeasurement: supportDeviceMeasurement,
        assignedDevices: assignedDevices,
        personalDevices: personalDevices,
      ),
    );
  }

  void removeDevice(Device device, MeasurementTypeContract measurementType) async {
    await _pairedDevicesDbProvider.remove(device);
    final assignedDevices = getAssignedDevices(measurementType);
    final personalDevices = getPersonalDevices(measurementType);

    emit(
      state.copyWith(
        assignedDevices: assignedDevices,
        personalDevices: personalDevices,
      ),
    );
  }
}
