import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/globals.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/utils/extensions/locale_extensions.dart';
import 'package:scalesoft_app/utils/extensions/theme_mode_extensions.dart';

@singleton
class AppSettingsBloc extends Bloc<AppSettingsBlocEvent, AppSettings> {
  final AppSettingsDbProvider _settingsDbProvider;

  AppSettingsBloc(
    this._settingsDbProvider,
  ) : super(
          _settingsDbProvider.read() ??
              AppSettings(
                themeModeLocal: buildConfig.themeMode.toLocal(),
                localLocale: buildConfig.locale.toLocal(),
                enabledNotifications: true,
                notifyAtStartOfMeasurement: true,
              ),
        ) {
    on<AppSettingsBlocEvent>(
      (event, emit) async {
        await event.when(
          initSettings: () {
            final appSettings = _getAppSettings();

            _settingsDbProvider.write(appSettings);
            emit(appSettings);
          },
          localeChanged: (Locale newLocale) {
            final appSettings = _settingsDbProvider.read() ??
                AppSettings(
                  themeModeLocal: buildConfig.themeMode.toLocal(),
                  localLocale: buildConfig.locale.toLocal(),
                );

            _settingsDbProvider.write(
              appSettings.copyWith(localLocale: newLocale.toLocal()),
            );

            emit(_getAppSettings());
          },
          themeChanged: (ThemeMode newThemeMode) async {
            final appSettings = _settingsDbProvider.read() ??
                AppSettings(
                  themeModeLocal: buildConfig.themeMode.toLocal(),
                  localLocale: buildConfig.locale.toLocal(),
                );

            await _settingsDbProvider.write(
              appSettings.copyWith(themeModeLocal: newThemeMode.toLocal()),
            );

            setSystemUIOverlayStyle(newThemeMode);

            emit(_getAppSettings());
            getIt<ContentBloc>()
                .add(OnAppearanceChangedContentEvent(newThemeMode));
          },
        );
      },
    );
  }

  void onLocaleChanged(Locale newLocale) {
    add(AppSettingsBlocEvent.localeChanged(newLocale));
  }

  void onThemeChanged(ThemeMode newTheme) {
    add(AppSettingsBlocEvent.themeChanged(newTheme));
  }

  void setSystemUIOverlayStyle(ThemeMode? mode) {
    SystemChrome.setSystemUIOverlayStyle(
      mode == ThemeMode.light
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  AppSettings _getAppSettings() {
    final appSettings = _settingsDbProvider.read() ??
        AppSettings(
          themeModeLocal: buildConfig.themeMode.toLocal(),
          localLocale: buildConfig.locale.toLocal(),
          enabledNotifications: true,
          notifyAtStartOfMeasurement: true,
        );

    return appSettings;
  }
}
