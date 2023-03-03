import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/model/theme_mode_local.dart';
import 'package:scalesoft_app/utils/extensions/locale_extensions.dart';

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
        localLocale: Locale(languageCode).toLocal(),
      ),
    );
  }

  Future<AppSettings> updateTheme(
    AppSettings acc, {
    required ThemeMode themeMode,
  }) {
    return save(
      acc.copyWith(
        themeModeLocal: themeMode.toLocal(),
      ),
    );
  }
}

abstract class SettingsDb {
  Future<AppSettings> save(AppSettings account);
  AppSettings? getLast();
}
