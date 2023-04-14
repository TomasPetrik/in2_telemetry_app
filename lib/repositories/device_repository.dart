import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/device_api_client.dart';
import 'package:scalesoft_app/api/model/device_model.dart';
import 'package:scalesoft_app/api/model/device_to_register.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class DeviceRepository {
  final DeviceApiClient deviceApiClient;
  final Session session;

  DeviceRepository(this.deviceApiClient, this.session);

  Future<List<DeviceModel>> getDeviceModels({
    required UserAccount userAccount,
  }) =>
      deviceApiClient.getDeviceModels(
        userAccount.hospital!.authData.baseUrl,
      );

  Future<void> registerDevice({
    required UserAccount userAccount,
    required DeviceToRegister deviceToRegister,
  }) =>
      deviceApiClient.registerDevice(
        userAccount.hospital!.authData.baseUrl,
        deviceToRegister,
      );
}
