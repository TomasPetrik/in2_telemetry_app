import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/globals.dart';

@preResolve
@lazySingleton
class SettingsService {
  SettingsService._() {
    localeChangedStream = _localeStreamController.stream;
    themeChangedStream = _themeModeStreamController.stream;
  }

  final _localeStreamController = StreamController<Locale>.broadcast();
  final _themeModeStreamController = StreamController<ThemeMode>.broadcast();
  late Stream<Locale> localeChangedStream;
  late Stream<ThemeMode> themeChangedStream;
  Locale? currentLocale;
  ThemeMode? currentThemeMode;

  @factoryMethod
  static Future<SettingsService> create() async {
    final instance = SettingsService._();
    await instance._init();
    return instance;
  }

  Future<void> _init() async {
    currentLocale = buildConfig.locale;
    currentThemeMode = buildConfig.themeMode;
  }

  void changeLocale(final Locale newLocale) {
    currentLocale = newLocale;
    _localeStreamController.sink.add(newLocale);
  }

  void changeThemeMode(final ThemeMode newThemeMode) {
    currentThemeMode = newThemeMode;
    _themeModeStreamController.sink.add(newThemeMode);
  }

  @disposeMethod
  Future<void> dispose() async {
    await _localeStreamController.close();
    await _themeModeStreamController.close();
  }
}
