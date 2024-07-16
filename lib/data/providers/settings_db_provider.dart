import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/configuration/hospitals_configuration.dart';
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

  Stream<AppSetting> watchSettings() {
    final stream = _database.select(_database.appSettings).watchSingleOrNull();
    stream.first.then((initialValue) {
      if (initialValue == null) {
        _createDefaultAppSettings();
      }
    });

    return stream.where((event) => event != null).cast();
  }

  Future<AppSetting> updateAppSettings(AppSettingsCompanion changes) async {
    final settingsExist = (await _database.select(_database.appSettings).getSingleOrNull()) != null;

    if (!settingsExist) {
      await _createDefaultAppSettings();
    }

    return (await _database.update(_database.appSettings).writeReturning(changes)).first;
  }

  Future<void> enableStagingHospitals() async {
    await updateAppSettings(const AppSettingsCompanion(enableStagingHospitals: Value(true)));
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
            lastHospitalId: HospitalsConfiguration.hospitals.firstWhere((x) => !x.isStaging).id,
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
