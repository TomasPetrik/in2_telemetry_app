import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'temperature_threshold_settings.freezed.dart';
part 'temperature_threshold_settings.g.dart';

@freezed
class TemperatureThresholdSetting with _$TemperatureThresholdSetting {
  const TemperatureThresholdSetting._();

  @HiveType(typeId: 51, adapterName: 'TemperatureThresholdSettingAdapter')
  factory TemperatureThresholdSetting(
    @HiveField(1) double? min,
    @HiveField(2) double? max,
  ) = _TemperatureThresholdSetting;

  factory TemperatureThresholdSetting.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$TemperatureThresholdSettingFromJson(json);

  @override
  String toString() => toJson().toString();
}
