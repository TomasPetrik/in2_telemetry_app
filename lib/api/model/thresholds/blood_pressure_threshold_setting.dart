import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'blood_pressure_threshold_setting.freezed.dart';
part 'blood_pressure_threshold_setting.g.dart';

@freezed
class BloodPressureThresholdSetting with _$BloodPressureThresholdSetting {
  const BloodPressureThresholdSetting._();

  @HiveType(typeId: 48, adapterName: 'BloodPressureThresholdSettingAdapter')
  factory BloodPressureThresholdSetting(
    @HiveField(1) int? systolicMin,
    @HiveField(2) int? systolicMax,
    @HiveField(3) int? diastolicMin,
    @HiveField(4) int? diastolicMax,
  ) = _BloodPressureThresholdSetting;

  factory BloodPressureThresholdSetting.fromJson(Map<String, dynamic> json) =>
      _$BloodPressureThresholdSettingFromJson(json);

  @override
  String toString() => toJson().toString();
}
