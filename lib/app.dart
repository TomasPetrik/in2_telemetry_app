import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_bloc.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/globals.dart';
import 'package:scalesoft_app/globals_initialization.dart';
import 'package:scalesoft_app/locales.dart';
import 'package:scalesoft_app/managers/background_measurement_manager.dart';
import 'package:scalesoft_app/data/providers/settings_db_provider.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/no_users_exception.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/managers/content_manager.dart';
import 'package:scalesoft_app/ui/routers/app_router.dart';
import 'package:scalesoft_app/ui/routers/routes/blank_route.dart';
import 'package:scalesoft_app/ui/routers/routes/dashboard_route.dart';
import 'package:scalesoft_app/ui/routers/routes/no_user_route.dart';
import 'package:scalesoft_app/ui/routers/routes/user_added_route.dart';
import 'package:scalesoft_app/ui/scale_app.dart';
import 'package:scalesoft_app/ui/screens/splash_screen.dart';
import 'package:scalesoft_app/utils/helpers/appearance_helper.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:scalesoft_app/data/app_database.dart';

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;

  /* Initialize assets first */
  tz.initializeTimeZones();
  await configureDependencies();

  getIt<ReportService>().trackEvent(severity: LogSeverity.info, message: 'BS - backgroundFetchHeadlessTask() called');

  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // Must be stopped immediately

    getIt<ReportService>().trackEvent(
      severity: LogSeverity.warning,
      message: 'BS - headless task exceeded allowed running-time: $taskId',
    );
    return;
  }

  getIt<ReportService>().trackEvent(severity: LogSeverity.info, message: 'BS - started sync');

  await getIt<SyncService>().syncAllData(syncAllUsers: true);

  getIt<ReportService>().trackEvent(severity: LogSeverity.info, message: 'BS - finished sync');

  BackgroundFetch.finish(taskId);
}

Future<void> run() async {
  await _main(themeMode: ThemeMode.dark, locale: cs);
}

Future<void> watchSyncBackgroundTaskImpl() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  getIt<BackgroundMeasurementManager>().configureBackgroundServiceMethodCallHandler();
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
      await configureDependencies();

      getIt<ContentBloc>().add(const CheckLastLoggedUserContentEvent());

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
      getIt<ReportService>().trackEvent(severity: LogSeverity.error, message: stackTrace.toString());
    },
  );
}

class ScalesoftApp extends StatefulWidget {
  const ScalesoftApp({super.key});

  @override
  State<ScalesoftApp> createState() => _ScalesoftAppState();
}

class _ScalesoftAppState extends State<ScalesoftApp> {
  GoRouter? _goRouter;
  bool _isInitializing = true;
  AppSetting? settings;

  @override
  Widget build(BuildContext context) {
    if (_isInitializing || settings == null) {
      return SplashScreen(
        loadingFunction: init,
        onLoaded: (result) => setState(() {
          _isInitializing = false;
          settings = result;
        }),
      );
    }

    final originalErrorHandler = FlutterError.onError;

    getIt<UserCubit>().stream.handleError(
          (e) => {
            if (e is NoUsersException && _goRouter != null)
              {
                _goRouter!.goNamed(NoUserRoute.name),
              },
          },
        );

    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NoUsersException && _goRouter != null) {
        _goRouter!.goNamed(NoUserRoute.name);
      } else if (originalErrorHandler != null) {
        originalErrorHandler(details);
      }
    };

    _goRouter = AppRouter().router;

    return ContentManager(
      goRouter: _goRouter!,
      onInit: (context, state) {
        final path = state.whenOrNull(
          unauthenticated: () => '/${NoUserRoute.name}',
          onUserAdded: (UserModel userAccount) => '/${UserAddedRoute.name}/${userAccount.id}',
          onDaylightAppearanceChanged: (originalLocation) => originalLocation,
          activeMode: (key) => '/${DashboardRoute.name}',
          tryCompleteAuth: (uri) => '/${BlankRoute.name}',
        );

        if (path != null) {
          _goRouter!.go(path);
        }
        return ScaleApp(
          goRouter: _goRouter!,
          settings: settings!,
        );
      },
      themeMode: buildConfig.themeMode,
    );
  }

  Future<AppSetting> init() async {
    final settingsDbProvider = getIt<SettingsDbProvider>();

    var appSettings = await settingsDbProvider.getSettings();

    AppearanceHelper.setSystemUIOverlayStyle(
      appSettings.themeMode,
    );

    final notificationsBloc = getIt<NotificationsBloc>();
    notificationsBloc.add(const NotificationsEvent.initPlugin());
    notificationsBloc.notificationsStreamController.stream.listen(
      (_) {
        _goRouter?.goNamed(DashboardRoute.name);
        getIt<CarePlanBloc>().add(const RefreshStateEvent());
      },
    );

    return appSettings;
  }
}
