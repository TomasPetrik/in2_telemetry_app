import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/constants/permissions.dart';
import 'package:scalesoft_app/cubit/device_management/device_management_state.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/providers/device_db_provider.dart';
import 'package:scalesoft_app/data/providers/device_prototype_db_provider.dart';
import 'package:scalesoft_app/model/device_model.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';

@injectable
class DeviceManagementCubit extends Cubit<DeviceManagementState> {
  final UserCubit _userCubit;
  final DeviceDbProvider _deviceDbProvider;
  final DevicePrototypeDbProvider _devicePrototypeDbProvider;
  late int userId;

  bool supportedDeviceMeasurement(MeasurementType measurementType) {
    return ConfigurationConstants.supportedDevices.any(
      (device) => device.supportedMeasurementTypes.contains(
        measurementType,
      ),
    );
  }

  Future<List<DeviceModel>> getAssignedDevices(MeasurementType measurementType) async {
    final userDevices = await _deviceDbProvider.getByUser(userId);
    return userDevices.where((x) => !x.isPersonal).toList();
  }

  //Personal devices which are not matching with user devices and user has also permission
  //for measurements with unknown devices <canMeasureWithUnknownDevice>
  Future<List<DeviceModel>> getPersonalDevices(MeasurementType measurementType) async {
    final user = _userCubit.state.allUsers.firstWhere((x) => x.id == userId);
    if (user.permissions.none((x) => x == Permissions.measureWithUnknownDevice)) {
      return [];
    }

    // Get paired devices of all users
    final pairedDevices = await _deviceDbProvider.getDistinctPairedDevices();

    final enabledDevicePrototypes = await _devicePrototypeDbProvider.getByUser(userId);

    // Filter out devices not enabled in user's hospital
    final allowedDevices = pairedDevices.where(
      (device) => enabledDevicePrototypes.any((prototype) => device.prototype.templateId == prototype.templateId),
    );

    // Filter out devices assigned to this user - these aren't personal devices.
    final result = allowedDevices.where((x) => x.isPersonal || x.prototype.userId != userId);

    return result.toList();
  }

  DeviceManagementCubit(
    this._deviceDbProvider,
    this._userCubit,
    this._devicePrototypeDbProvider,
  ) : super(
          const DeviceManagementState(
            assignedDevices: null,
            personalDevices: null,
            supportDeviceMeasurement: null,
          ),
        );

  void init(
    MeasurementType measurementType,
    Set<MeasurementType>? allMeasurementTypes,
    int userId,
  ) async {
    this.userId = userId;

    final supportDeviceMeasurement = supportedDeviceMeasurement(measurementType);
    final assignedDevices = await getAssignedDevices(measurementType);
    final personalDevices = await getPersonalDevices(measurementType);
    final hasMeasurementTabs = allMeasurementTypes != null && allMeasurementTypes.length > 1;

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

  void selectMeasurementType(MeasurementType measurementType) async {
    final supportDeviceMeasurement = supportedDeviceMeasurement(measurementType);
    final assignedDevices = await getAssignedDevices(measurementType);
    final personalDevices = await getPersonalDevices(measurementType);

    emit(
      state.copyWith(
        selectedMeasurementType: measurementType,
        supportDeviceMeasurement: supportDeviceMeasurement,
        assignedDevices: assignedDevices,
        personalDevices: personalDevices,
      ),
    );
  }

  void removeDevice(DeviceModel device, MeasurementType measurementType) async {
    if (device.isPersonal) {
      await _deviceDbProvider.removeDevice(device.id);
    } else {
      await _deviceDbProvider.markAsUnpaired(device.id);
    }

    final assignedDevices = await getAssignedDevices(measurementType);
    final personalDevices = await getPersonalDevices(measurementType);

    emit(
      state.copyWith(
        assignedDevices: assignedDevices,
        personalDevices: personalDevices,
      ),
    );
  }
}
