
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/notifications_settings_screen.dart';

class NotificationRoute extends ApplicationRoute {
  static const name = 'notification';
  static const path = 'notification';

  NotificationRoute({
    required super.navigator,
    super.routes,
  });

  @override
  GoRoute get route {
    return GoRoute(
      path: path,
      name: name,
      routes: routes,
      parentNavigatorKey: navigator,
      builder: (context, state) {
        return const NotificationsSettingsScreen();
      },
    );
  }
}
