import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scalesoft_app/api/dto/user_info.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/model/measurement_info.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/auth_screen.dart';
import 'package:scalesoft_app/ui/screens/beurer_screen.dart';
import 'package:scalesoft_app/ui/screens/dashboard_screen.dart';
import 'package:scalesoft_app/ui/screens/measurement_result_screen.dart';
import 'package:scalesoft_app/ui/screens/omron_screen.dart';
import 'package:scalesoft_app/ui/screens/search_devices_screen.dart';
import 'package:scalesoft_app/ui/screens/select_device_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUpGetIt();
  getIt<Dio>(instanceName: Constants.privateDioName).interceptors.add(getIt<TokenInterceptor>());

  runApp(const ScalesoftApp());
}

class ScalesoftApp extends StatelessWidget {
  const ScalesoftApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        // GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case AuthScreen.routeName:
                return AuthScreen();
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
                return MeasurementResultScreen(measurementInfo: measurementInfo);
              default:
                return AuthScreen();
            }
          },
        );
      },
    );
  }
}

class GlobalMaterialLocalizations {}
