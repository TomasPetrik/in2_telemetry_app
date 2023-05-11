import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:scalesoft_app/model/local_locale.dart';
import 'package:scalesoft_app/model/theme_mode_local.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';
part 'app_settings.hive.dart';

@freezed
class AppSettings with _$AppSettings {
  const AppSettings._();

  @HiveType(typeId: 1, adapterName: 'AppSettingsAdapter')
  factory AppSettings({
    @HiveField(0) required ThemeModeLocal themeModeLocal,
    @HiveField(1) required LocalLocale localLocale,
    @HiveField(2) bool? enabledNotifications,
    @HiveField(3) bool? notifyAtStartOfMeasurement,
    @HiveField(4) bool? notify10minBeforeMeasurement,
    @HiveField(5) bool? autosetAppearance,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
