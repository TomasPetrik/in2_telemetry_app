import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/omron_flow_screen.dart';

class OmronFlowRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'omron-flow';
  static const path = '/omron-flow';

  OmronFlowRoute({
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
          final userId = int.parse(state.uri.queryParameters['userId']!);

          final measurementTypeName = state.uri.queryParameters['measurementType']!;
          final MeasurementType measurementType = MeasurementType.values.firstWhere(
            (measurementType) => measurementType.name == measurementTypeName,
          );
          final device = state.extra as DeviceCreateModel;

          return OmronFlowScreen(
            userId: userId,
            device: device,
            measurementType: measurementType,
          );
        },
      ),
    );
  }
}
