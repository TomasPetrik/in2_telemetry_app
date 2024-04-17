import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
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
          final userId = int.parse(state.params['userId']!);
          final measurementTypeName = state.params['measurementType'];
          final showAllMeasurementTypes =
              bool.parse(state.params['showAllMeasurementTypes'] ?? 'false');
          MeasurementType? measurementType;
          if (measurementTypeName?.isNotEmpty == true) {
            measurementType = MeasurementType.values.firstWhereOrNull(
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
