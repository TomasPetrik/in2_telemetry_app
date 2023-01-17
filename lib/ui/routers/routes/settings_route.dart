import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/configuration_screen.dart';

class SettingsRoute extends ApplicationRoute {
  static const name = 'settings';
  static const path = 'settings';

  SettingsRoute({
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
        return ConfigurationScreen(
          key: UniqueKey(),
        );
      },
    );
  }
}
