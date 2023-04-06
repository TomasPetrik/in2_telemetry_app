import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/omron_flow_screen.dart';
import 'package:scalesoft_app/utils/constants.dart';

class OmronFlowRoute extends ApplicationRoute with PageBuilderMixin {
  static const name = 'omron-flow';
  static const path = '/omron-flow/:userId/:deviceId/:measurementType';

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
          final userId = state.params['userId']!;
          final deviceId = state.params['deviceId']!;
          final measurementTypeName = state.params['measurementType']!;
          final MeasurementType measurementType =
              MeasurementType.values.firstWhere(
            (measurementType) => measurementType.name == measurementTypeName,
          );

          final Device device;
          if (deviceId.contains(':')) {
            device = getIt<PairedDevicesDbProvider>().get(deviceId)!;
          } else {
            final localDeviceId = int.parse(deviceId);
            device = Constants.supportedDevices.firstWhere(
              (device) => device.localId == localDeviceId,
            );
          }

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
