import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/device_model.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/application_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/page_builder_mixin.dart';
import 'package:scalesoft_app/ui/screens/omron_flow_screen.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';

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
          final MeasurementTypeContract measurementType =
              MeasurementTypeContract.values.firstWhere(
            (measurementType) => measurementType.name == measurementTypeName,
          );

          assert(
            deviceId != null ||
                (modelName != null && deviceManufacturer != null),
            'either deviceId or (modelName and deviceManufacturer) shoudn\'t be null',
          );

          final user = getIt<AccountDbProvider>().get(userId)!;

          Device? device;

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
