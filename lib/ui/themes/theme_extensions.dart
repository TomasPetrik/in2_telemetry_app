import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/scale_colors.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_dark.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';

extension ThemeExtensions on ThemeData {
  static final ScaleColors _lightColors = ScaleColorsLight();
  static final ScaleColors _darkColors = ScaleColorsDark();

  ScaleColors get colors => switch (brightness) {
      Brightness.dark => _darkColors,
      Brightness.light => _lightColors,
    };
}
