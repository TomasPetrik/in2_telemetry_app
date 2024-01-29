import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:scalesoft_app/api/model/measurement/shortness_of_breath_value.dart';

part 'shortness_of_breath_threshold_settings.freezed.dart';

part 'shortness_of_breath_threshold_settings.g.dart';

@freezed
class ShortnessOfBreathThresholdSetting
    with _$ShortnessOfBreathThresholdSetting {
  const ShortnessOfBreathThresholdSetting._();

  @HiveType(typeId: 53, adapterName: 'ShortnessOfBreathThresholdSettingAdapter')
  factory ShortnessOfBreathThresholdSetting(
    @HiveField(1) ShortnessOfBreathValue? max,
  ) = _ShortnessOfBreathThresholdSetting;

  factory ShortnessOfBreathThresholdSetting.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ShortnessOfBreathThresholdSettingFromJson(json);

  @override
  String toString() => toJson().toString();
}
