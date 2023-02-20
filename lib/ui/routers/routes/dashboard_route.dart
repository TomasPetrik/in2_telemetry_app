import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/dashboard_page.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class DashboardRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'dashboard';
  static const path = '/dashboard';

  DashboardRoute({
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
      pageBuilder: pageBuilder(
        withTransition: false,
        builder: (state) {
          return DashboardPage(
            key: UniqueKey(),
          );
        },
      ),
    );
  }
}
