import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/action_button_type.dart';
import 'package:scalesoft_app/data/entities/enums/device_model_type.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_flow.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';

class DevicePrototypeModel {
  final int id;
  final int templateId;
  final String modelName;
  final String? deviceManufacturer;
  final String visibleName;
  final String bluetoothName;
  final String? bluetoothPairingName;
  final DeviceModelType deviceModelType;
  final List<MeasurementType> supportedMeasurementTypes;
  final bool requiresPairing;
  final bool askToActivateBt;
  final bool askToConfirmMeasurement;
  final String imagePath;
  final MeasurementFlow measurementFlow;
  final ActionButtonType? actionButtonType;
  final int remoteId;

  final String? aboutUrl;

  // Each user can have different device prototypes (in reality, prototypes should be identical in a given hospital)
  final int userId;

  DevicePrototypeModel(
    this.id,
    this.templateId,
    this.modelName,
    this.deviceManufacturer,
    this.visibleName,
    this.bluetoothName,
    this.bluetoothPairingName,
    this.deviceModelType,
    this.userId,
    this.supportedMeasurementTypes,
    this.requiresPairing,
    this.askToActivateBt,
    this.askToConfirmMeasurement,
    this.imagePath,
    this.measurementFlow,
    this.actionButtonType,
    this.remoteId, {
    this.aboutUrl,
  });

  factory DevicePrototypeModel.fromEntity(DevicePrototype entity) {
    return DevicePrototypeModel(
      entity.id,
      entity.templateData.localId,
      entity.templateData.modelName,
      entity.templateData.deviceManufacturer,
      entity.templateData.visibleName,
      entity.templateData.bluetoothName,
      entity.templateData.bluetoothPairingName,
      entity.templateData.deviceModelType,
      entity.userId,
      entity.templateData.supportedMeasurementTypes,
      entity.templateData.requiresPairing,
      entity.templateData.askToActivateBt,
      entity.templateData.askToConfirmMeasurement,
      entity.templateData.imagePath,
      entity.templateData.measurementFlow,
      entity.templateData.actionButtonType,
      entity.remoteId,
      aboutUrl: entity.aboutUrl,
    );
  }
}
