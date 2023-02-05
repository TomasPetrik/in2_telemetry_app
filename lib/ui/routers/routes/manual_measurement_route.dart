import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/manual_measurement_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class ManualMeasurementRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'manual-measurement';
  static const path = 'manual-measurement';

  ManualMeasurementRoute({
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
          final measurementType = state.extra as MeasurementType?;
          return ManualMeasurementScreen(
            measurementType: measurementType,
          );
        },
      ),
    );
  }
}
