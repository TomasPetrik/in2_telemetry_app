import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/api/model/report/report.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_event.dart';
import 'package:scalesoft_app/globals.dart';
import 'package:scalesoft_app/globals_initialization.dart';
import 'package:scalesoft_app/locales.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/ui/managers/content_manager.dart';
import 'package:scalesoft_app/ui/routers/app_router.dart';
import 'package:scalesoft_app/ui/routers/routes/appearance_route.dart';
import 'package:scalesoft_app/ui/routers/routes/blank_route.dart';
import 'package:scalesoft_app/ui/routers/routes/configuration_route.dart';
import 'package:scalesoft_app/ui/routers/routes/dashboard_route.dart';
import 'package:scalesoft_app/ui/routers/routes/no_user_route.dart';
import 'package:scalesoft_app/ui/routers/routes/user_added_route.dart';
import 'package:scalesoft_app/ui/scale_app.dart';
import 'package:scalesoft_app/ui/screens/splash_screen.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/utils/extensions/locale_extensions.dart';
import 'package:scalesoft_app/utils/extensions/theme_mode_extensions.dart';
import 'package:scalesoft_app/utils/helpers/appearance_helper.dart';
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

Future<void> run() async {
  await _main(themeMode: ThemeMode.dark, locale: cs);
}

Future<void> _main({
  required final ThemeMode themeMode,
  required final Locale locale,
}) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      tz.initializeTimeZones();
      initializeGlobals(themeMode: themeMode, locale: locale);

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]).then(
        (value) => runApp(const ScalesoftApp()),
      );
    },
    (error, stackTrace) {
      if (!getIt.isRegistered<ReportService>()) {
        debugPrintStack(stackTrace: stackTrace, label: error.toString());
        return;
      }
      getIt<ReportService>()
          .trackEvent(severity: Severity.error, message: stackTrace.toString());
    },
  );

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
          tryCompleteAuth: (uri) => '/${BlankRoute.name}',
        );

        if (path != null) {
          _goRouter!.go(path);
        }
        return ScaleApp(goRouter: _goRouter!);
      },
      themeMode: buildConfig.themeMode,
    );
  }

  Future<void> init() async {
    await Hive.initFlutter();

    await configureDependencies();

    getIt<Dio>(instanceName: ConfigurationConstants.privateDioName)
        .interceptors
        .add(getIt<TokenInterceptor>());

    final settingsDbProvider = getIt<AppSettingsDbProvider>();

    var appSettings = settingsDbProvider.read();
    if (appSettings == null) {
      appSettings = AppSettings(
        themeModeLocal: buildConfig.themeMode.toLocal(),
        localLocale: buildConfig.locale.toLocal(),
        enabledNotifications: true,
        notifyAtStartOfMeasurement: true,
        autosetAppearance: false,
      );
      settingsDbProvider.write(appSettings);
    }

    AppearanceHelper.setSystemUIOverlayStyle(
      appSettings.themeModeLocal.themeMode,
    );

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
