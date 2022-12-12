import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc_event.dart';
import 'package:scalesoft_app/globals.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/services/settings_service.dart';

@injectable
class SettingsBloc extends Bloc<SettingsBlocEvent, AppSettings> {
  final SettingsDbProvider settingsDbProvider;
  final SettingsService settingsService;

  SettingsBloc(
    this.settingsService,
    this.settingsDbProvider,
  )   : _localeService = settingsService,
        super(
          settingsDbProvider.read() ??
              AppSettings(
                themeMode: buildConfig.themeMode,
                locale: buildConfig.locale,
              ),
        ) {
    _localeService.localeChangedStream.listen(onLocaleChanged);
    _localeService.themeChangedStream.listen(onThemeChanged);
    on<SettingsChangeLocaleEvent>((event, emit) {
      _localeService.changeLocale(event.newLocale);
      emit(_getState());
    });
    on<SettingsChangeThemeEvent>((event, emit) {
      _localeService.changeThemeMode(event.newThemeMode);

      final appSettings = settingsDbProvider.read() ??
          AppSettings(
            themeMode: buildConfig.themeMode,
            locale: buildConfig.locale,
          );

      settingsDbProvider.write(
        appSettings.copyWith(themeMode: event.newThemeMode),
      );

      setSystemUIOverlayStyle(event.newThemeMode);

      emit(_getState());
    });
    on<OnSettingsChangedEvent>((event, emit) {
      emit(_getState());
    });
  }

  final SettingsService _localeService;

  void onLocaleChanged(Locale newLocale) {
    add(OnSettingsChangedEvent());
  }

  void onThemeChanged(ThemeMode newTheme) {
    add(OnSettingsChangedEvent());
  }

  void setSystemUIOverlayStyle(ThemeMode? mode) {
    SystemChrome.setSystemUIOverlayStyle(
      mode == ThemeMode.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  AppSettings _getState() {
    final currentTheme = _localeService.currentThemeMode ?? state.themeMode;
    final currentLocale = _localeService.currentLocale ?? state.locale;
    return AppSettings(
      themeMode: currentTheme,
      locale: currentLocale,
    );
  }
}
