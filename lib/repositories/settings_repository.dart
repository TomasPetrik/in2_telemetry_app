import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/app_settings.dart';

class SettingsRepository {
  final SettingsDb _settingsDb;

  const SettingsRepository._(this._settingsDb);

  const SettingsRepository.builder({
    required SettingsDb settingsDb,
  }) : this._(settingsDb);

  Future<AppSettings> save(AppSettings account) async {
    return _settingsDb.save(account);
  }

  AppSettings? get() {
    return _settingsDb.getLast();
  }

  Future<AppSettings> updateLanguage(
    AppSettings acc, {
    required String languageCode,
  }) {
    return save(
      acc.copyWith(
        locale: Locale(languageCode),
      ),
    );
  }

  Future<AppSettings> updateTheme(
    AppSettings acc, {
    required ThemeMode themeMode,
  }) {
    return save(
      acc.copyWith(
        themeMode: themeMode,
      ),
    );
  }
}

abstract class SettingsDb {
  Future<AppSettings> save(AppSettings account);
  AppSettings? getLast();
}
