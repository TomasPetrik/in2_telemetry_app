import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/theme_mode_local.dart';

extension ThemeModeExtension on ThemeMode {
  ThemeModeLocal toLocal() {
    return ThemeModeLocal(
      index: this == ThemeMode.light
          ? 0
          : this == ThemeMode.dark
              ? 1
              : 2,
    );
  }
}
