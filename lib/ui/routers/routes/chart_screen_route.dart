import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/chart_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class ChartRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'chart';
  static const path = '/chart/:dateTime/:userId/:measurementType';

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
          final userId = state.params['userId']!;
          final userAccount = getIt<AccountDbProvider>().get(userId)!;
          final dateTimeString = state.params['dateTime']!;
          final initDt = DateTime.parse(dateTimeString);
          final measurementTypeName = state.params['measurementType']!;
          final measurementType = MeasurementTypeContract.values.firstWhere(
            (measurementType) => measurementType.name == measurementTypeName,
          );

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
