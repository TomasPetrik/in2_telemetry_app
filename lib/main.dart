import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/dto/user_info.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc.dart';
import 'package:scalesoft_app/globals_initialization.dart';
import 'package:scalesoft_app/locales.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/model/measurement_info.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/appearance_settings_screen.dart';
import 'package:scalesoft_app/ui/screens/auth_screen.dart';
import 'package:scalesoft_app/ui/screens/beurer_screen.dart';
import 'package:scalesoft_app/ui/screens/configuration_screen.dart';
import 'package:scalesoft_app/ui/screens/dashboard_screen.dart';
import 'package:scalesoft_app/ui/screens/measurement_result_screen.dart';
import 'package:scalesoft_app/ui/screens/notifications_settings_screen.dart';
import 'package:scalesoft_app/ui/screens/omron_screen.dart';
import 'package:scalesoft_app/ui/screens/search_devices_screen.dart';
import 'package:scalesoft_app/ui/screens/select_device_screen.dart';
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
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case AuthScreen.routeName:
                    return AuthScreen();
                  case ConfigurationScreen.routeName:
                    return const ConfigurationScreen();
                  case AppearanceSettingsScreen.routeName:
                    return const AppearanceSettingsScreen();
                  case NotificationsSettingsScreen.routeName:
                    return const NotificationsSettingsScreen();
                  case DashboardScreen.routeName:
                    final userInfo = routeSettings.arguments as UserInfo;
                    return DashboardScreen(userInfo: userInfo);
                  case BeurerScreen.routeName:
                    return const BeurerScreen();
                  case OmronScreen.routeName:
                    return const OmronScreen();
                  case SearchDevicesScreen.routeName:
                    return const SearchDevicesScreen();
                  case SelectDeviceScreen.routeName:
                    return const SelectDeviceScreen();
                  case MeasurementResultScreen.routeName:
                    final measurementInfo = routeSettings.arguments as MeasurementInfo;
                    return MeasurementResultScreen(
                      measurementInfo: measurementInfo,
                    );
                  default:
                    return AuthScreen();
                }
              },
            );
          },
        );
      },
    );
  }

  Future<void> init() async {
    await Hive.initFlutter();

    final settingsDbProvider = getIt<SettingsDbProvider>();
    await settingsDbProvider.init();
  }
}

class GlobalMaterialLocalizations {}
