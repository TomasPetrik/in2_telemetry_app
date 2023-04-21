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
    @JsonKey(ignore: true) @HiveField(3) String? visibleName,
    @JsonKey(ignore: true) @HiveField(4) String? bluetoothName,
    @JsonKey(ignore: true) @HiveField(6) int? localId,
    @JsonKey(ignore: true) @HiveField(7) DeviceModelType? deviceModelType,
    @JsonKey(ignore: true)
    @HiveField(8)
        List<MeasurementType>? supportedMeasurementTypes,
    @JsonKey(ignore: true) @HiveField(9) String? imagePath,
    @JsonKey(ignore: true) @HiveField(10) bool? reqPairing,
    @JsonKey(ignore: true) @HiveField(11) DateTime? addedAt,
    @JsonKey(ignore: true) @HiveField(12) bool? askToActivateBt,
    @JsonKey(ignore: true) @HiveField(13) bool? askToConfirmMeasurement,
    @JsonKey(ignore: true) @HiveField(14) ActionButtonType? actionButtonType,
    @JsonKey(ignore: true) @HiveField(15) bool? devIdIsName,
    @JsonKey(ignore: true) @HiveField(16) bool? wasPaired,
    @JsonKey(ignore: true) @HiveField(17) bool? isLendedDevice,
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
}
