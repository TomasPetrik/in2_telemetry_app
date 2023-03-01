import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/settings/time_setting.dart';

part 'time_settings.freezed.dart';
part 'time_settings.g.dart';

@freezed
class TimeSettings with _$TimeSettings {
  factory TimeSettings(
    List<TimeSetting> settings,
    String userMuid,
  ) = _TimeSettings;

  factory TimeSettings.fromJson(Map<String, dynamic> json) =>
      _$TimeSettingsFromJson(json);

  @override
  String toString() => toJson().toString();
}
