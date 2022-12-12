import 'package:flutter/material.dart';

abstract class SettingsBlocEvent {}

class OnSettingsChangedEvent extends SettingsBlocEvent {}

class SettingsChangeLocaleEvent extends SettingsBlocEvent {
  SettingsChangeLocaleEvent({
    required this.newLocale,
  });
  final Locale newLocale;
}

class SettingsChangeThemeEvent extends SettingsBlocEvent {
  SettingsChangeThemeEvent({
    required this.newThemeMode,
  });
  final ThemeMode newThemeMode;
}
