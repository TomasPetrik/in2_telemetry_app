import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_dark.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';

class AppearanceHelper {
  static void setSystemUIOverlayStyle(ThemeMode mode) {
    final brightness = switch (mode) {
      ThemeMode.system =>
        SchedulerBinding.instance.platformDispatcher.platformBrightness,
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
    };
    final colors =
        brightness == Brightness.light ? ScaleColorsLight() : ScaleColorsDark();
    final iconsBrightness =
        brightness == Brightness.light ? Brightness.dark : Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: colors.paperAccent,
        statusBarColor: colors.transparent,
        statusBarIconBrightness: iconsBrightness,
        systemNavigationBarIconBrightness: iconsBrightness));
  }
}
