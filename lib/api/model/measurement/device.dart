import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';

part 'device.freezed.dart';
part 'device.g.dart';

@freezed
class Device with _$Device {
  const Device._();

  @HiveType(typeId: 33, adapterName: 'DeviceAdapter')
  const factory Device({
    @HiveField(0) String? deviceIdentifier,
    @HiveField(1) String? modelName,
    @HiveField(2) String? deviceManufacturer,
    @JsonKey(includeToJson: false) @HiveField(3) String? visibleName,
    @JsonKey(includeToJson: false) @HiveField(4) String? bluetoothName,
    @JsonKey(includeToJson: false) @HiveField(5) String? bluetoothPairingName,
    @JsonKey(includeToJson: false) @HiveField(6) int? localId,
    @JsonKey(includeToJson: false)
    @HiveField(7)
    DeviceModelType? deviceModelType,
    @JsonKey(includeToJson: false)
    @HiveField(8)
    List<MeasurementType>? supportedMeasurementTypes,
    @JsonKey(includeToJson: false) @HiveField(9) String? imagePath,
    @JsonKey(includeToJson: false) @HiveField(10) bool? reqPairing,
    @JsonKey(includeToJson: false) @HiveField(11) DateTime? addedAt,
    @JsonKey(includeToJson: false) @HiveField(12) bool? askToActivateBt,
    @JsonKey(includeToJson: false) @HiveField(13) bool? askToConfirmMeasurement,
    @JsonKey(includeToJson: false)
    @HiveField(14)
    ActionButtonType? actionButtonType,
    @JsonKey(includeToJson: false) @HiveField(16) bool? wasPaired,
    @JsonKey(includeToJson: false) @HiveField(17) bool? isLendedDevice,
    @JsonKey(includeToJson: false) @HiveField(18) String? aboutUrl,
    @HiveField(19) String? assignedIdentifier,
    @JsonKey(includeToJson: false)
    @HiveField(20) String? bluetoothAddress,
    @JsonKey(includeToJson: false)
    @HiveField(21, defaultValue: MeasurementFlow.foreground) @Default(MeasurementFlow.foreground)
    MeasurementFlow? measurementFlow,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  @override
  String toString() => toJson().toString();
}

@HiveType(typeId: 37)
enum ActionButtonType {
  @HiveField(0)
  regular,
  @HiveField(1)
  startButton,
}

@HiveType(typeId: 34)
enum DeviceModelType {
  @HiveField(0)
  beurerBm77,
  @HiveField(1)
  omronM7,
  @HiveField(3)
  e8x,
}

@HiveType(typeId: 38)
enum MeasurementFlow {
  @HiveField(0)
  none(0),
  @HiveField(1)
  foreground(1 << 0),
  @HiveField(1 << 1)
  background(1 << 2),
  @HiveField(3)
  all(0xFF);

  final int value;

  const MeasurementFlow(this.value);

  bool hasFlag(MeasurementFlow flag) {
    return flag.value & value != 0;
  }
}
