import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/care_plan_detail_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class CarePlanDetailRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'care-plan-detail';
  static const path = 'care-planuser-detail';

  CarePlanDetailRoute({
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
          final carePlanId = state.extra! as int;
          final carePlan = getIt<AccountDbProvider>().getCarePlan(carePlanId)!;
          return CarePlanDetailScreen(
            carePlan: carePlan,
          );
        },
      ),
    );
  }
}
