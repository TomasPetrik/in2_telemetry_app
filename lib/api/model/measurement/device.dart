import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';

part 'device.freezed.dart';
part 'device.g.dart';
part 'device.hive.dart';

@freezed
class Device with _$Device {
  const Device._();

  @HiveType(typeId: 33, adapterName: 'DeviceAdapter')
  const factory Device({
    @HiveField(0) String? deviceIdentifier,
    @HiveField(1) String? modelName,
    @HiveField(2) String? deviceManufacturer,
    @JsonKey(ignore: false) @HiveField(3) String? visibleName,
    @JsonKey(ignore: false) @HiveField(4) String? bluetoothName,
    @JsonKey(ignore: false) @HiveField(6) int? localId,
    @JsonKey(ignore: false) @HiveField(7) DeviceModelType? deviceModelType,
    @JsonKey(ignore: false)
    @HiveField(8)
        List<MeasurementType>? supportedMeasurementTypes,
    @JsonKey(ignore: false) @HiveField(9) String? imagePath,
    @JsonKey(ignore: false) @HiveField(10) bool? reqPairing,
    @JsonKey(ignore: false) @HiveField(11) DateTime? addedAt,
    @JsonKey(ignore: false) @HiveField(12) bool? askToActivateBt,
    @JsonKey(ignore: false) @HiveField(13) bool? askToConfirmMeasurement,
    @JsonKey(ignore: false) @HiveField(14) ActionButtonType? actionButtonType,
    @JsonKey(ignore: false) @HiveField(15) bool? devIdIsName,
    @JsonKey(ignore: false) @HiveField(16) bool? wasPaired,
    @JsonKey(ignore: false) @HiveField(17) bool? isLendedDevice,
    @JsonKey(ignore: false) @HiveField(18) String? aboutUrl,
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
