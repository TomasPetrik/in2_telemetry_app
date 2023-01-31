import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/managers/auth_manager.dart';
import 'package:scalesoft_app/ui/routers/routes/appearance_route.dart';
import 'package:scalesoft_app/ui/routers/routes/care_plan_detail_route.dart';
import 'package:scalesoft_app/ui/routers/routes/dashboard_route.dart';
import 'package:scalesoft_app/ui/routers/routes/hospital_detail_route.dart';
import 'package:scalesoft_app/ui/routers/routes/no_user_route.dart';
import 'package:scalesoft_app/ui/routers/routes/notification_route.dart';
import 'package:scalesoft_app/ui/routers/routes/results_route.dart';
import 'package:scalesoft_app/ui/routers/routes/settings_route.dart';
import 'package:scalesoft_app/ui/routers/routes/user_added_route.dart';
import 'package:scalesoft_app/ui/routers/routes/user_detail_route.dart';
import 'package:scalesoft_app/ui/screens/home_screen.dart';

class AppRouter {
  final navRoot = GlobalKey<NavigatorState>();

  final navTabBar = GlobalKey<NavigatorState>();
  final settingsKey = GlobalKey<NavigatorState>();

  GoRouter get router {
    return GoRouter(
      navigatorKey: navRoot,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) {
            return const AuthManager();
          },
          redirect: (context, state) {
            if (state.location != '/') {
              return state.location;
            }

            final ContentState userContentState = getIt<ContentBloc>().state;

            final path = userContentState.whenOrNull(
              unauthenticated: () => '/${NoUserRoute.name}',
              onAppearanceChanged: () =>
                  '/${SettingsRoute.name}/${AppearanceRoute.name}',
              onUserAdded: (UserAccount userAccount) =>
                  '/${UserAddedRoute.name}/${userAccount.user.muid}',
              activeSingleUser: (UserAccount userAccount) =>
                  '/${DashboardRoute.name}',
              activeAllUsers: () => '/multi-user',
            );

            return path;
          },
          routes: [
            ShellRoute(
              navigatorKey: navTabBar,
              builder: (context, state, child) {
                return HomeScreen(
                  path: state.location,
                  child: child,
                );
              },
              routes: [
                DashboardRoute(navigator: navTabBar).route,
                ResultsRoute(navigator: navTabBar).route,
                SettingsRoute(
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
            UserAddedRoute(navigator: navRoot).route,
            NoUserRoute(navigator: navRoot).route,
          ],
        ),
      ],
    );
  }
}
