import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/globals.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/model/theme_mode_local.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/utils/extensions/locale_extensions.dart';

@singleton
class SettingsBloc extends Bloc<SettingsBlocEvent, AppSettings> {
  final SettingsDbProvider _settingsDbProvider;

  SettingsBloc(
    this._settingsDbProvider,
  ) : super(
          _settingsDbProvider.read() ??
              AppSettings(
                themeModeLocal: buildConfig.themeMode.toLocal(),
                localLocale: buildConfig.locale.toLocal(),
              ),
        ) {
    on<SettingsBlocEvent>(
      (event, emit) async {
        await event.when(
          initSettings: () {
            emit(_getAppSettings());
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
          enableNotifications: (enabled) async {
            final appSettings = _settingsDbProvider.read();

            if (appSettings == null) return;

            await _settingsDbProvider.write(
              appSettings.copyWith(enabledNotifications: enabled),
            );
            emit(_getAppSettings());
          },
          notifyAtStartOfMeasurement: (bool enabled) async {
            final appSettings = _settingsDbProvider.read();

            if (appSettings == null) return;

            await _settingsDbProvider.write(
              appSettings.copyWith(notifyAtStartOfMeasurement: enabled),
            );
            emit(_getAppSettings());
          },
          notify10MinBeforeMeasurement: (bool enabled) async {
            final appSettings = _settingsDbProvider.read();

            if (appSettings == null) return;

            await _settingsDbProvider.write(
              appSettings.copyWith(notify10minBeforeMeasurement: enabled),
            );
            emit(_getAppSettings());
          },
        );
      },
    );
  }

  void onLocaleChanged(Locale newLocale) {
    add(SettingsBlocEvent.localeChanged(newLocale));
  }

  void onThemeChanged(ThemeMode newTheme) {
    add(SettingsBlocEvent.themeChanged(newTheme));
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
        );

    return appSettings;
  }
}
