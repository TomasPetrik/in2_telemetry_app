import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/config.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/globals.dart';

@injectable
class SettingsDbProvider {
  final AppDatabase _database;

  SettingsDbProvider(this._database);

  Future<AppSetting> getSettings() async {
    final settings = await _database.select(_database.appSettings).getSingleOrNull();
    if (settings != null) {
      return settings;
    }

    return await _createDefaultAppSettings();
  }

  Future<AppSetting> updateAppSettings(AppSettingsCompanion changes) async {
    final settingsExist = (await _database.select(_database.appSettings).getSingleOrNull()) != null;

    if (!settingsExist) {
      await _createDefaultAppSettings();
    }

    return (await _database.update(_database.appSettings).writeReturning(changes)).first;
  }

  Future<AppSetting> _createDefaultAppSettings() async {
    // Make sure we don't accidentally create multiple entities
    await _database.delete(_database.appSettings).go();

    return await _database.into(_database.appSettings).insertReturning(
          AppSettingsCompanion.insert(
            themeMode: buildConfig.themeMode,
            languageCode: buildConfig.locale.languageCode,
            enableNotifications: true,
            notifyAtStartOfMeasurement: true,
            notify10minBeforeMeasurement: false,
            lastHospitalId: Config.value.hospitals.first.id,
            showAllUsers: false,
            currentCodeVerifier: '',
          ),
        );
  }

  Future<bool> isMultiUser() async {
    final settings = await getSettings();
    return settings.showAllUsers;
  }

  Future<bool> setIsMultiUser(bool isMultiUser) async {
    final result = await updateAppSettings(AppSettingsCompanion(showAllUsers: Value(isMultiUser)));
    return result.showAllUsers;
  }
}
