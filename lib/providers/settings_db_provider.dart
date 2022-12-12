import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/providers/box_provider.dart';
import 'package:scalesoft_app/providers/storage_provider.dart';

@singleton
class SettingsDbProvider extends BoxProvider<SettingsLocal> implements StorageProvider<AppSettings> {
  @override
  final String boxName = 'settingsBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(SettingsLocalAdapter());
  }

  @override
  AppSettings? read() {
    if (box.isNotEmpty) {
      final local = box.values.first;

      return AppSettings(
        themeMode: ThemeMode.values[local.themeMode],
        locale: Locale(local.languageCode),
      );
    }
    return null;
  }

  @override
  Future<void> write(AppSettings appSettings) async {
    await box.clear();
    box.add(
      SettingsLocal(
        themeMode: appSettings.themeMode.index,
        languageCode: appSettings.locale.languageCode,
      ),
    );
  }
}
