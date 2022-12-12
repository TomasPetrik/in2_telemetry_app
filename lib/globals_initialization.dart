import 'package:flutter/material.dart';
import 'package:scalesoft_app/globals.dart' as globals;
import 'package:scalesoft_app/model/build_config.dart';

Future<void> initializeGlobals({
  required final bool isDevel,
  required final ThemeMode themeMode,
  required final Locale locale,
}) async {
  globals.isDevel = isDevel;
  globals.buildConfig = _getBuildConfig(isDevel, themeMode, locale);
}

BuildConfig _getBuildConfig(final bool isDevel, final ThemeMode themeMode, final Locale locale) {
  final buildConfig = BuildConfig(
    themeMode: themeMode,
    locale: locale,
  );
  return buildConfig;
}
