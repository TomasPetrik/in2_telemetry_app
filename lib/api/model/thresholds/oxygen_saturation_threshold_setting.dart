import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'oxygen_saturation_threshold_setting.freezed.dart';
part 'oxygen_saturation_threshold_setting.g.dart';
part 'oxygen_saturation_threshold_setting.hive.dart';

@freezed
class OxygenSaturationThresholdSetting with _$OxygenSaturationThresholdSetting {
  const OxygenSaturationThresholdSetting._();

  @HiveType(typeId: 50, adapterName: 'OxygenSaturationThresholdSettingAdapter')
  factory OxygenSaturationThresholdSetting(
    @HiveField(1) double? percentageMin,
    @HiveField(2) double? percentageMax,
  ) = _OxygenSaturationThresholdSetting;

  factory OxygenSaturationThresholdSetting.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$OxygenSaturationThresholdSettingFromJson(json);

  @override
  String toString() => toJson().toString();
}
