import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc.dart';
import 'package:scalesoft_app/globals_initialization.dart';
import 'package:scalesoft_app/locales.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/managers/content_manager.dart';
import 'package:scalesoft_app/ui/routers/app_router.dart';
import 'package:scalesoft_app/ui/scale_app.dart';
import 'package:scalesoft_app/ui/screens/splash_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

Future<void> main() async {
  await _main(themeMode: ThemeMode.dark, locale: cz, isDev: true);
}

Future<void> _main({
  required final ThemeMode themeMode,
  required final Locale locale,
  required final bool isDev,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeGlobals(themeMode: themeMode, locale: locale, isDev: isDev);
  WebView.debugLoggingSettings.enabled = false;

  runApp(const ScalesoftApp());
}

class ScalesoftApp extends StatefulWidget {
  const ScalesoftApp({Key? key}) : super(key: key);

  @override
  State<ScalesoftApp> createState() => _ScalesoftAppState();
}

class _ScalesoftAppState extends State<ScalesoftApp> {
  bool _isInitializing = true;

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return SplashScreen(
        loadingFunction: init,
        onLoaded: () => setState(() {
          _isInitializing = false;
        }),
      );
    }

    SettingsBloc settingsBloc = getIt<SettingsBloc>();

    return ContentManager(
      onInit: (context, state) {
        return BlocBuilder<SettingsBloc, AppSettings>(
          bloc: settingsBloc,
          builder: (context, settingsState) {
            return ScaleApp(
              themeMode: settingsState.themeMode,
              goRouter: AppRouter().router,
            );
          },
        );
      },
      themeMode: ThemeMode.dark,
    );
  }

  Future<void> init() async {
    await configureDependencies();

    getIt<Dio>(instanceName: Constants.privateDioName)
        .interceptors
        .add(getIt<TokenInterceptor>());

    await Hive.initFlutter();

    final settingsDbProvider = getIt<SettingsDbProvider>();
    await settingsDbProvider.init();

    final accountDbProvider = getIt<AccountDbProvider>();
    await accountDbProvider.init();
  }
}

class GlobalMaterialLocalizations {}
