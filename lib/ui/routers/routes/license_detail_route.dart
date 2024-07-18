import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/oss_licenses.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/licence_detail_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class LicenseDetailRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'license-detail';
  static const path = 'license-detail';

  LicenseDetailRoute({
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
          final package = state.extra! as Package;
          return LicenceDetailScreen(package: package);
        },
      ),
    );
  }
}
