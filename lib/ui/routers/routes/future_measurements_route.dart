import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/future_measurements_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class FutureMeasurementsRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'future-measurements';
  static const path = '/future-measurements';

  FutureMeasurementsRoute({
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
          final usersEvaluationsDay =
              getIt<Session>().usersEvaluationsDayRestoration!;

          return FutureMeasurementsScreen(
            usersEvaluationsDay: usersEvaluationsDay,
          );
        },
      ),
    );
  }
}
