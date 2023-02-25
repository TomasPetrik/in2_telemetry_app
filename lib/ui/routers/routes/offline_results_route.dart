import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/offline_results_screen.dart';

class OfflineResultsRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'offline-results';
  static const path = '/offline-results';

  OfflineResultsRoute({
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
          return const OfflineResultsScreen();
        },
      ),
    );
  }
}
