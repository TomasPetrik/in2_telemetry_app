import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings_bloc_event.freezed.dart';

@freezed
class AppSettingsBlocEvent with _$AppSettingsBlocEvent {
  const factory AppSettingsBlocEvent.initSettings() = _InitSettings;
  const factory AppSettingsBlocEvent.localeChanged(Locale newLocale) =
      _LocaleChanged;
  const factory AppSettingsBlocEvent.themeChanged(ThemeMode newThemeMode) =
      _ThemeChanged;
}
