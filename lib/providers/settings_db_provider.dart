import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/model/local_locale.dart';
import 'package:scalesoft_app/model/theme_mode_local.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class AppSettingsDbProvider extends BoxProvider<AppSettings> {
  @override
  @PostConstruct(preResolve: true)
  Future<void> init() async => super.init();

  @override
  final String boxName = 'appSettingsBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(ThemeModeLocalAdapter());
    Hive.registerAdapter(LocalLocaleAdapter());
  }

  AppSettings? read() {
    try {
      if (box.isNotEmpty) {
        final local = box.values.first;

        return local;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> write(AppSettings appSettings) async {
    await box.clear();
    box.add(appSettings);
  }
}
