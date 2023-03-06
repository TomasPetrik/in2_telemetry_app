import 'package:flutter/material.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/utils/extensions/locale_extensions.dart';
import 'package:scalesoft_app/utils/extensions/theme_mode_extensions.dart';

class AppSettingsRepository {
  final AppSettingsDb _settingsDb;

  const AppSettingsRepository._(this._settingsDb);

  const AppSettingsRepository.builder({
    required AppSettingsDb settingsDb,
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

abstract class AppSettingsDb {
  Future<AppSettings> save(AppSettings account);
  AppSettings? getLast();
}
