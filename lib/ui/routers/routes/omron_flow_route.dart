import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
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
          final deviceId = state.uri.queryParameters['deviceId'];
          final measurementTypeName = state.uri.queryParameters['measurementType']!;
          final modelName = state.uri.queryParameters['modelName'];
          final deviceManufacturer = state.uri.queryParameters['deviceManufacturer'];
          final MeasurementType measurementType =
              MeasurementType.values.firstWhere(
            (measurementType) => measurementType.name == measurementTypeName,
          );

          assert(
            deviceId != null ||
                (modelName != null && deviceManufacturer != null),
            'either deviceId or (modelName and deviceManufacturer) shoudn\'t be null',
          );

          final user = getIt<AccountDbProvider>().get(userId)!;

          SourceDeviceContract? device;

          if (deviceId != null) {
            //1. Search dev in stored paired devices
            device = getIt<PairedDevicesDbProvider>().get(deviceId);
          }

          if (device == null) {
            device = ConfigurationConstants.supportedDevices.firstWhere(
              (device) =>
                  device.modelName == modelName &&
                  device.deviceManufacturer == deviceManufacturer,
            );

            //2. if user has assigned devices, just add him his ID  to search this specific dev
            device = device.copyWith(deviceIdentifier: deviceId);
          }

          //also add device's reference

          final DeviceModel? deviceModel =
              user.supportedDeviceModels?.firstWhereOrNull(
            (deviceModel) =>
                deviceModel.modelName == device!.modelName &&
                deviceModel.manufacturer == device.deviceManufacturer,
          );
          if (deviceModel != null) {
            device = device.copyWith(aboutUrl: deviceModel.aboutUrl);
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
