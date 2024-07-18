import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/future_measurements_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';

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
          final measurementResults = state.extra as List<MeasurementResultViewModel>? ??[];

          return FutureMeasurementsScreen(
            results: measurementResults,
          );
        },
      ),
    );
  }
}
