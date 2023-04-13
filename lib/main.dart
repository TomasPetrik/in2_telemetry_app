import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_event.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc.dart';
import 'package:scalesoft_app/bloc/settings/app_settings_bloc_event.dart';
import 'package:scalesoft_app/globals_initialization.dart';
import 'package:scalesoft_app/locales.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/calendar_db_provider.dart';
import 'package:scalesoft_app/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/providers/session_db_provider.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/ui/managers/content_manager.dart';
import 'package:scalesoft_app/ui/routers/app_router.dart';
import 'package:scalesoft_app/ui/routers/routes/appearance_route.dart';
import 'package:scalesoft_app/ui/routers/routes/configuration_route.dart';
import 'package:scalesoft_app/ui/routers/routes/dashboard_route.dart';
import 'package:scalesoft_app/ui/routers/routes/no_user_route.dart';
import 'package:scalesoft_app/ui/routers/routes/user_added_route.dart';
import 'package:scalesoft_app/ui/scale_app.dart';
import 'package:scalesoft_app/ui/screens/splash_screen.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:timezone/data/latest_all.dart' as tz;

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

  FlutterLocalNotificationsPlugin().show(
    3001,
    'Headless',
    'Headless body',
    const NotificationDetails(),
  );
  await getIt<SyncService>().syncAllData();
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  await _main(themeMode: ThemeMode.dark, locale: cs);
}

Future<void> _main({
  required final ThemeMode themeMode,
  required final Locale locale,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  initializeGlobals(themeMode: themeMode, locale: locale);
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
  GoRouter? _goRouter;
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

    _goRouter = AppRouter().router;
    return ContentManager(
      goRouter: _goRouter!,
      onInit: (context, state) {
        final path = state.whenOrNull(
          unauthenticated: () => '/${NoUserRoute.name}',
          onUserAdded: (UserAccount userAccount) =>
              '/${UserAddedRoute.name}/${userAccount.user.muid}',
          onAppearanceChanged: (_) =>
              '/${ConfigurationRoute.name}/${AppearanceRoute.name}',
          onDaylightAppearanceChanged: (originalLocation) => originalLocation,
          activeMode: (key) => '/${DashboardRoute.name}',
        );

        if (path != null) {
          _goRouter!.go(path);
        }
        return ScaleApp(goRouter: _goRouter!);
      },
      themeMode: ThemeMode.dark,
    );
  }

  Future<void> init() async {
    configureDependencies(context);

    getIt<Dio>(instanceName: Constants.privateDioName)
        .interceptors
        .add(getIt<TokenInterceptor>());

    await Hive.initFlutter();

    final settingsDbProvider = getIt<AppSettingsDbProvider>();
    await settingsDbProvider.init();

    final accountDbProvider = getIt<AccountDbProvider>();
    await accountDbProvider.init();

    final pendindResultsDbProvider = getIt<PendingResultsDbProvider>();
    await pendindResultsDbProvider.init();

    final sessionDbProvider = getIt<SessionDbProvider>();
    await sessionDbProvider.init();

    final pairedDevicesDbProvider = getIt<PairedDevicesDbProvider>();
    await pairedDevicesDbProvider.init();

    final calendarDbProvider = getIt<CalendarDbProvider>();
    await calendarDbProvider.init();

    final measurementDbProvider = getIt<MeasurementsDbProvider>();
    await measurementDbProvider.init();

    getIt<AppSettingsBloc>().add(const AppSettingsBlocEvent.initSettings());
    final notifcationsBloc = getIt<NotificationsBloc>();
    notifcationsBloc.add(const NotificationsEvent.initPlugin());
    notifcationsBloc.notificationsStreamController.stream.listen(
      (_) {
        _goRouter?.goNamed(DashboardRoute.name);
        getIt<CarePlanBloc>().add(const RefreshStateEvent());
      },
    );
  }
}
