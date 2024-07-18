import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/globals.dart';
import 'package:scalesoft_app/data/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/utils/helpers/appearance_helper.dart';

@singleton
class AppSettingsBloc extends Bloc<AppSettingsBlocEvent, AppSetting?> {
  final SettingsDbProvider _settingsDbProvider;

  AppSettingsBloc(
    this._settingsDbProvider,
  ) : super(
          null,
        ) {
    on<AppSettingsBlocEvent>(
      (event, emit) async {
        await event.when(
          initSettings: () async {
            final appSettings = await _settingsDbProvider.getSettings();
            emit(appSettings);
          },
          localeChanged: (Locale newLocale) async {
            final settings = await _settingsDbProvider
                .updateAppSettings(AppSettingsCompanion(languageCode: Value(newLocale.languageCode)));

            emit(settings);
          },
          themeChanged: (ThemeMode newThemeMode) async {
            final settings =
                await _settingsDbProvider.updateAppSettings(AppSettingsCompanion(themeMode: Value(newThemeMode)));

            AppearanceHelper.setSystemUIOverlayStyle(newThemeMode);

            emit(settings);
            getIt<ContentBloc>().add(OnAppearanceChangedContentEvent(newThemeMode));
          },
          setAutoAppearance: (bool enabled) async {
            final newThemeMode = enabled ? ThemeMode.system : buildConfig.themeMode;

            final settings =
                await _settingsDbProvider.updateAppSettings(AppSettingsCompanion(themeMode: Value(newThemeMode)));

            if (newThemeMode == ThemeMode.system) {
              final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
              AppearanceHelper.setSystemUIOverlayStyleByBrightness(brightness);
            } else {
              AppearanceHelper.setSystemUIOverlayStyle(newThemeMode);
            }

            emit(settings);

            getIt<ContentBloc>().add(OnAppearanceChangedContentEvent(newThemeMode));
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
}
