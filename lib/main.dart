import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc.dart';
import 'package:scalesoft_app/globals_initialization.dart';
import 'package:scalesoft_app/locales.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/main_screen.dart';
import 'package:scalesoft_app/ui/screens/splash_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/dark_mode.dart';
import 'package:scalesoft_app/ui/themes/light_mode.dart';

Future<void> main() async {
  await _main(themeMode: ThemeMode.dark, locale: cz, isDevel: true);
}

Future<void> _main({
  required final ThemeMode themeMode,
  required final Locale locale,
  required final bool isDevel,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeGlobals(themeMode: themeMode, locale: locale, isDevel: isDevel);
  WebView.debugLoggingSettings.enabled = false;

  await configureDependencies();
  getIt<Dio>(instanceName: Constants.privateDioName).interceptors.add(getIt<TokenInterceptor>());

  runApp(const ScalesoftApp());
}

class ScalesoftApp extends StatefulWidget {
  const ScalesoftApp({Key? key}) : super(key: key);

  @override
  State<ScalesoftApp> createState() => _ScalesoftAppState();
}

class _ScalesoftAppState extends State<ScalesoftApp> {
  bool _isInitializing = true;
  late SettingsBloc settingsBloc;

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

    settingsBloc = getIt<SettingsBloc>();

    return BlocBuilder<SettingsBloc, AppSettings>(
      bloc: settingsBloc,
      builder: (context, state) {
        return MaterialApp(
          restorationScopeId: 'app',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            //GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          theme: LightMode.theme,
          darkTheme: DarkMode.theme,
          themeMode: settingsBloc.state.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }

  Future<void> init() async {
    await Hive.initFlutter();

    final settingsDbProvider = getIt<SettingsDbProvider>();
    await settingsDbProvider.init();

    final accountDbProvider = getIt<AccountDbProvider>();
    await accountDbProvider.init();
  }
}

class GlobalMaterialLocalizations {}
