import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/globals.dart';
import 'package:scalesoft_app/localization/generated/l10n.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/dark_mode.dart';
import 'package:scalesoft_app/ui/themes/light_mode.dart';

class ScaleApp extends StatelessWidget {
  const ScaleApp({
    super.key,
    required this.goRouter,
  });

  final GoRouter goRouter;

  @override
  Widget build(BuildContext context) {
    final appSettings = getIt<AppSettingsDbProvider>().read();
    final themeMode =
        appSettings?.themeModeLocal.themeMode ?? buildConfig.themeMode;
    return MaterialApp.router(
      title: 'Telemetry App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        I10n.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      onGenerateTitle: (BuildContext context) => localization.appTitle,
      supportedLocales: const [
        Locale('cs'),
      ],
      theme: LightMode.theme,
      darkTheme: DarkMode.theme,
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}
