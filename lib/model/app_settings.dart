import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'app_settings.g.dart';

const defaultLocale = Locale('cz');
const defaultThemeMode = ThemeMode.dark;

class AppSettings extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;

  const AppSettings({
    required this.themeMode,
    required this.locale,
  });

  const AppSettings.builder({
    ThemeMode? themeMode,
    Locale? locale,
  }) : this(
          themeMode: themeMode ?? defaultThemeMode,
          locale: locale ?? defaultLocale,
        );

  @override
  List<Object?> get props => [
        themeMode,
        locale,
      ];

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

@HiveType(typeId: 1)
class SettingsLocal extends HiveObject {
  @HiveField(0)
  final int themeMode;
  @HiveField(1)
  final String languageCode;

  SettingsLocal({
    required this.themeMode,
    required this.languageCode,
  });
}
