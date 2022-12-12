import 'package:flutter/material.dart';

class BuildConfig {
  BuildConfig({
    required this.themeMode,
    required this.locale,
  });

  final ThemeMode themeMode;
  final Locale locale;

  BuildConfig cloneWith({
    final ThemeMode? themeMode,
    final Locale? locale,
  }) =>
      BuildConfig(
        themeMode: themeMode ?? this.themeMode,
        locale: locale ?? this.locale,
      );
}
