import 'package:background_fetch/background_fetch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc.dart';
import 'package:scalesoft_app/bloc/settings/settings_bloc_event.dart';
import 'package:scalesoft_app/globals_initialization.dart';
import 'package:scalesoft_app/locales.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/providers/session_db_provider.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/ui/managers/content_manager.dart';
import 'package:scalesoft_app/ui/routers/app_router.dart';
import 'package:scalesoft_app/ui/scale_app.dart';
import 'package:scalesoft_app/ui/screens/splash_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    debugPrint("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  debugPrint('[BackgroundFetch] Headless event received.');
  // Do your work here...
  await getIt<SyncService>().syncAllData();
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  await _main(themeMode: ThemeMode.dark, locale: cs, isDev: true);
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

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
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

    return ContentManager(
      onInit: (context, state) {
        return ScaleApp(
          goRouter: AppRouter().router,
        );
      },
      themeMode: ThemeMode.dark,
    );
  }

  Future<void> init() async {
    configureDependencies();

    getIt<Dio>(instanceName: Constants.privateDioName)
        .interceptors
        .add(getIt<TokenInterceptor>());

    await Hive.initFlutter();

    final settingsDbProvider = getIt<SettingsDbProvider>();
    await settingsDbProvider.init();

    final accountDbProvider = getIt<AccountDbProvider>();
    await accountDbProvider.init();

    final pendindResultsDbProvider = getIt<PendingResultsDbProvider>();
    await pendindResultsDbProvider.init();

    final sessionDbProvider = getIt<SessionDbProvider>();
    await sessionDbProvider.init();

    getIt<SettingsBloc>().add(const SettingsBlocEvent.initSettings());
  }
}

class GlobalMaterialLocalizations {}
