import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'heart_rate_threshold_setting.freezed.dart';
part 'heart_rate_threshold_setting.g.dart';

@freezed
class HeartRateThresholdSetting with _$HeartRateThresholdSetting {
  const HeartRateThresholdSetting._();

  @HiveType(typeId: 49, adapterName: 'HeartRateThresholdSettingAdapter')
  factory HeartRateThresholdSetting(
    @HiveField(1) int? min,
    @HiveField(2) int? max,
  ) = _HeartRateThresholdSetting;

  factory HeartRateThresholdSetting.fromJson(Map<String, dynamic> json) =>
      _$HeartRateThresholdSettingFromJson(json);

  @override
  String toString() => toJson().toString();
}
