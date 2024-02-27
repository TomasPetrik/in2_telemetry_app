import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/metering_first_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class MeteringFirstRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'metering-first';
  static const path = '/metering-first/:userId/:measurementType/:showAllMeasurementTypes';

  MeteringFirstRoute({
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
          final measurementTypeName = state.params['measurementType'];
          final showAllMeasurementTypes =
              bool.parse(state.params['showAllMeasurementTypes'] ?? 'false');
          MeasurementTypeContract? measurementType;
          if (measurementTypeName?.isNotEmpty == true) {
            measurementType = MeasurementTypeContract.values.firstWhereOrNull(
              (measurementType) => measurementType.name == measurementTypeName,
            );
          }

          return MeteringFirstScreen(
            userId: userId,
            selectedMeasurementType: measurementType,
            showAllMeasurementTypes: showAllMeasurementTypes,
          );
        },
      ),
    );
  }
}
