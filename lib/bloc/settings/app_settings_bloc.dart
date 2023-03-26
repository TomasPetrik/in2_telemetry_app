import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/globals.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/location_service.dart';
import 'package:scalesoft_app/utils/extensions/locale_extensions.dart';
import 'package:scalesoft_app/utils/extensions/theme_mode_extensions.dart';
import 'package:scalesoft_app/utils/helpers/appearance_helper.dart';

@singleton
class AppSettingsBloc extends Bloc<AppSettingsBlocEvent, AppSettings> {
  final AppSettingsDbProvider _settingsDbProvider;
  final LocationService _locationService;

  AppSettingsBloc(
    this._settingsDbProvider,
    this._locationService,
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
          initSettings: () async {
            final appSettings = _getAppSettings();

            _settingsDbProvider.write(appSettings);
            emit(appSettings);
          },
          localeChanged: (Locale newLocale) {
            final appSettings = _getAppSettings();

            _settingsDbProvider.write(
              appSettings.copyWith(localLocale: newLocale.toLocal()),
            );

            emit(_getAppSettings());
          },
          themeChanged: (ThemeMode newThemeMode) async {
            final appSettings = _getAppSettings();

            AppearanceHelper.setSystemUIOverlayStyle(newThemeMode);

            await _settingsDbProvider.write(
              appSettings.copyWith(themeModeLocal: newThemeMode.toLocal()),
            );

            emit(_getAppSettings());
            getIt<ContentBloc>()
                .add(OnAppearanceChangedContentEvent(newThemeMode));
          },
          setAutoAppearance: (bool enabled) async {
            final appSettings = _getAppSettings();
            final newAppSettings = appSettings.copyWith(
              autosetAppearance: enabled,
            );

            _settingsDbProvider.write(newAppSettings);
            emit(newAppSettings);

            if (enabled) {
              add(const AppSettingsBlocEvent.detectDayLightAndSetTheme());
            }
          },
          detectDayLightAndSetTheme: () async {
            final dayLightThemeMode =
                await _locationService.getThemeModeByDayLight();

            final appSettings = _getAppSettings();
            final newAppSettings = appSettings.copyWith(
              themeModeLocal: dayLightThemeMode.toLocal(),
            );
            await _settingsDbProvider.write(newAppSettings);
            emit(newAppSettings);

            getIt<ContentBloc>()
                .add(OnAppearanceChangedContentEvent(dayLightThemeMode));
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
