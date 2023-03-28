import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/results_history_screen.dart';

class ResultsHistoryRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'results-history';
  static const path = '/results-history';

  ResultsHistoryRoute({
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

          return ResultsHistoryScreen(
            usersEvaluationsDay: usersEvaluationsDay,
          );
        },
      ),
    );
  }
}
