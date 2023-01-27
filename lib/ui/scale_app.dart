import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/themes/dark_mode.dart';
import 'package:scalesoft_app/ui/themes/light_mode.dart';

class ScaleApp extends StatelessWidget {
  const ScaleApp({
    super.key,
    required this.themeMode,
    required this.goRouter,
  });

  final ThemeMode themeMode;
  final GoRouter goRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'app',
      title: 'Telemetry App',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
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
