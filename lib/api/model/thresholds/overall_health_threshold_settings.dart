import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:scalesoft_app/api/model/measurement/overall_health_value.dart';

part 'overall_health_threshold_settings.freezed.dart';

part 'overall_health_threshold_settings.g.dart';

part 'overall_health_threshold_settings.hive.dart';

@freezed
class OverallHealthThresholdSetting with _$OverallHealthThresholdSetting {
  const OverallHealthThresholdSetting._();

  @HiveType(typeId: 52, adapterName: 'OverallHealthThresholdSettingAdapter')
  factory OverallHealthThresholdSetting(
    @HiveField(1) OverallHealthValue? max,
  ) = _OverallHealthThresholdSetting;

  factory OverallHealthThresholdSetting.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$OverallHealthThresholdSettingFromJson(json);

  @override
  String toString() => toJson().toString();
}
