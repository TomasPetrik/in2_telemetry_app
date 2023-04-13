import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/add_device_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';

class AddDeviceRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'add-device';
  static const path = '/add-device/:userId/:measurementType';

  AddDeviceRoute({
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
          final MeasurementType measurementType =
              MeasurementType.values.firstWhere(
            (measurementType) => measurementType.name == measurementTypeName,
          );

          return AddDeviceScreen(
            userId: userId,
            measurementType: measurementType,
          );
        },
      ),
    );
  }
}
