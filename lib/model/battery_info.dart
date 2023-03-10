import 'package:freezed_annotation/freezed_annotation.dart';

part 'battery_info.freezed.dart';
part 'battery_info.g.dart';



@freezed
class BatteryInfo with _$BatteryInfo {
  const factory BatteryInfo({
    required String batteryLevel, //0x2A19
  }) = _BatteryInfo;

  factory BatteryInfo.fromJson(Map<String, Object?> json) =>
      _$BatteryInfoFromJson(json);
}
