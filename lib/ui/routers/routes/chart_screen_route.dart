import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/chart_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class ChartRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'chart';
  static const path = '/chart';

  ChartRoute({
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
          final args = state.extra! as List<Object>;
          final initDt = args[0] as DateTime;
          final userId = args[1] as String;
          final measurementType = args[2] as MeasurementType;

          final userAccount = getIt<AccountDbProvider>().get(userId)!;
          return ChartScreen(
            initDt: initDt,
            userAccount: userAccount,
            measurementType: measurementType,
          );
        },
      ),
    );
  }
}
