import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/setup_watch_screen.dart';

class SetupWatchRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'setup-watch';
  static const path = '/setup-watch';

  SetupWatchRoute({
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
          return SetupWatchScreen();
        },
      ),
    );
  }
}
