import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/how_it_works_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class HowItWorksRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'how-it-works';
  static const path = '/how-it-works';

  HowItWorksRoute({
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
          return const HowItWorksScreen();
        },
      ),
    );
  }
}
