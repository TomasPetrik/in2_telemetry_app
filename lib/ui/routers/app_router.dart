import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/managers/auth_manager.dart';
import 'package:scalesoft_app/ui/routers/routes/add_device_route.dart';
import 'package:scalesoft_app/ui/routers/routes/appearance_route.dart';
import 'package:scalesoft_app/ui/routers/routes/blank_route.dart';
import 'package:scalesoft_app/ui/routers/routes/calendar_route.dart';
import 'package:scalesoft_app/ui/routers/routes/care_plan_detail_route.dart';
import 'package:scalesoft_app/ui/routers/routes/chart_screen_route.dart';
import 'package:scalesoft_app/ui/routers/routes/configuration_route.dart';
import 'package:scalesoft_app/ui/routers/routes/dashboard_route.dart';
import 'package:scalesoft_app/ui/routers/routes/device_search_route.dart';
import 'package:scalesoft_app/ui/routers/routes/future_measurements_route.dart';
import 'package:scalesoft_app/ui/routers/routes/hospital_detail_route.dart';
import 'package:scalesoft_app/ui/routers/routes/license_detail_route.dart';
import 'package:scalesoft_app/ui/routers/routes/licenses_route.dart';
import 'package:scalesoft_app/ui/routers/routes/logs_detail_route.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_measurement_route.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_route.dart';
import 'package:scalesoft_app/ui/routers/routes/metering_first_route.dart';
import 'package:scalesoft_app/ui/routers/routes/no_user_route.dart';
import 'package:scalesoft_app/ui/routers/routes/notification_route.dart';
import 'package:scalesoft_app/ui/routers/routes/offline_results_route.dart';
import 'package:scalesoft_app/ui/routers/routes/omron_flow_route.dart';
import 'package:scalesoft_app/ui/routers/routes/register_device_detail_route.dart';
import 'package:scalesoft_app/ui/routers/routes/register_device_success_route.dart';
import 'package:scalesoft_app/ui/routers/routes/results_history_route.dart';
import 'package:scalesoft_app/ui/routers/routes/results_route.dart';
import 'package:scalesoft_app/ui/routers/routes/user_added_route.dart';
import 'package:scalesoft_app/ui/routers/routes/user_detail_route.dart';
import 'package:scalesoft_app/ui/screens/blank_screen.dart';
import 'package:scalesoft_app/ui/screens/home_screen.dart';

class AppRouter {
  final navRoot = GlobalKey<NavigatorState>();
  final navAuthManager = GlobalKey<NavigatorState>();
  final navTabBar = GlobalKey<NavigatorState>();
  final settingsKey = GlobalKey<NavigatorState>();

  GoRouter get router {
    return GoRouter(
      navigatorKey: navRoot,
      initialLocation: '/',
      errorBuilder: (context, state) => const BlankScreen(),
      routes: [
        ShellRoute(
          navigatorKey: navAuthManager,
          builder: (context, __, child) {
            return AuthManager(
              child: child,
            );
          },
          routes: [
            BlankRoute(navigator: navAuthManager).route,
            ShellRoute(
              navigatorKey: navTabBar,
              builder: (context, state, child) {
                return HomeScreen(
                  path: state.location,
                  child: child,
                );
              },
              routes: [
                DashboardRoute(
                  navigator: navTabBar,
                ).route,
                ResultsRoute(navigator: navTabBar).route,
                ConfigurationRoute(
                  navigator: navTabBar,
                  routes: [
                    AppearanceRoute(navigator: navTabBar).route,
                    NotificationRoute(navigator: navTabBar).route,
                    UserDetailRoute(navigator: navTabBar).route,
                    HospitalDetailRoute(navigator: navTabBar).route,
                    CarePlanDetailRoute(navigator: navTabBar).route,
                  ],
                ).route,
              ],
            ),
            UserAddedRoute(navigator: navAuthManager).route,
            NoUserRoute(navigator: navAuthManager).route,
            ManualMeasurementRoute(navigator: navAuthManager).route,
            OmronFlowRoute(navigator: navAuthManager).route,
            CalendarRoute(navigator: navAuthManager).route,
            OfflineResultsRoute(navigator: navAuthManager).route,
            ResultsHistoryRoute(navigator: navAuthManager).route,
            FutureMeasurementsRoute(navigator: navAuthManager).route,
            ChartRoute(navigator: navAuthManager).route,
            MeteringFirstRoute(navigator: navAuthManager).route,
            AddDeviceRoute(navigator: navAuthManager).route,
            DeviceSearchRoute(navigator: navAuthManager).route,
            RegisterDeviceDetailRoute(navigator: navAuthManager).route,
            RegisterDeviceSuccessRoute(navigator: navAuthManager).route,
            ManualRoute(navigator: navAuthManager).route,
            LicensesRoute(navigator: navAuthManager).route,
            LicenseDetailRoute(navigator: navAuthManager).route,
            LogsDetailRoute(navigator: navAuthManager).route,
          ],
        ),
      ],
    );
  }
}
