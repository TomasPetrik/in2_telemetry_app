import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/action_button_type.dart';
import 'package:scalesoft_app/data/entities/enums/device_model_type.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_flow.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';

part 'device_prototype_template.g.dart';

@JsonSerializable()
class DevicePrototypeTemplate {
  int localId;
  String modelName;
  String? deviceManufacturer;
  String visibleName;
  String bluetoothName;
  String? bluetoothPairingName;
  DeviceModelType deviceModelType;
  List<MeasurementType> supportedMeasurementTypes;
  bool requiresPairing;
  bool askToActivateBt;
  bool askToConfirmMeasurement;
  String imagePath;
  MeasurementFlow measurementFlow;
  ActionButtonType? actionButtonType;

  DevicePrototypeTemplate({
    required this.localId,
    required this.modelName,
    this.deviceManufacturer,
    required this.visibleName,
    required this.bluetoothName,
    this.bluetoothPairingName,
    required this.deviceModelType,
    required this.supportedMeasurementTypes,
    this.requiresPairing = false,
    this.askToActivateBt = false,
    this.askToConfirmMeasurement = false,
    required this.imagePath,
    required this.measurementFlow,
    this.actionButtonType,
  });

  factory DevicePrototypeTemplate.fromJson(Map<String, dynamic> json) => _$DevicePrototypeTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$DevicePrototypeTemplateToJson(this);

  static TypeConverter<DevicePrototypeTemplate, String> converter = TypeConverter.json(
    fromJson: (json) => DevicePrototypeTemplate.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );
}
