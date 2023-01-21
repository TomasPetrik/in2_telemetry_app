import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/appearance_settings_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class AppearanceRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'appearance';
  static const path = 'appearance';

  AppearanceRoute({
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
        withTransition: true,
        builder: (state) {
          return const AppearanceSettingsScreen();
        },
      ),
    );
  }
}
