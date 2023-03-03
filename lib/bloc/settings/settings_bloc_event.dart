import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_bloc_event.freezed.dart';

@freezed
class SettingsBlocEvent with _$SettingsBlocEvent {
  const factory SettingsBlocEvent.initSettings() = _InitSettings;
  const factory SettingsBlocEvent.localeChanged(Locale newLocale) =
      _LocaleChanged;
  const factory SettingsBlocEvent.themeChanged(ThemeMode newThemeMode) =
      _ThemeChanged;
  const factory SettingsBlocEvent.enableNotifications(bool enabled) =
      _EnableNotifications;

  const factory SettingsBlocEvent.notifyAtStartOfMeasurement(bool enabled) =
      _NotifyAtStartOfMeasurement;
  const factory SettingsBlocEvent.notify10MinBeforeMeasurement(bool enabled) =
      _Notify10MinBeforeMeasurement;
}
