import 'package:flutter/material.dart';
import 'package:scalesoft_app/globals.dart' as globals;
import 'package:scalesoft_app/model/build_config.dart';

void initializeGlobals({
  required final ThemeMode themeMode,
  required final Locale locale,
}) {
  globals.buildConfig = _getBuildConfig(themeMode, locale);
}

BuildConfig _getBuildConfig(
  final ThemeMode themeMode,
  final Locale locale,
) {
  final buildConfig = BuildConfig(
    themeMode: themeMode,
    locale: locale,
  );
  return buildConfig;
}
