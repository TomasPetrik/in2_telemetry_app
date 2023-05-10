import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/omron_flow_screen.dart';
import 'package:scalesoft_app/utils/constants.dart';

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
          final userId = state.queryParams['userId']!;
          final deviceId = state.queryParams['deviceId'];
          final measurementTypeName = state.queryParams['measurementType']!;
          final modelName = state.queryParams['modelName'];
          final deviceManufacturer = state.queryParams['deviceManufacturer'];
          final MeasurementType measurementType =
              MeasurementType.values.firstWhere(
            (measurementType) => measurementType.name == measurementTypeName,
          );

          assert(
            deviceId != null ||
                (modelName != null && deviceManufacturer != null),
            'either deviceId or (modelName and deviceManufacturer) shoudn\'t be null',
          );

          final Device device;

          if (deviceId != null) {
            device = getIt<PairedDevicesDbProvider>().get(deviceId)!;
          } else {
            device = Constants.supportedDevices.firstWhere(
              (device) =>
                  device.modelName == modelName &&
                  device.deviceManufacturer == deviceManufacturer,
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
