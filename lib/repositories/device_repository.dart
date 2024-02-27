import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/device_api_client.dart';
import 'package:scalesoft_app/api/contracts/device/device_prototype_contract.dart';
import 'package:scalesoft_app/api/contracts/device/device_create_contract.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class DeviceRepository {
  final DeviceApiClient deviceApiClient;
  final Session session;

  DeviceRepository(this.deviceApiClient, this.session);

  Future<List<DeviceModel>> getDeviceModels({
    required UserAccount userAccount,
  }) {
    session.token = userAccount.authToken;
    return deviceApiClient.getDeviceModels(
      userAccount.hospital!.authData.baseUrl,
    );
  }

  Future<void> registerDevice({
    required UserAccount userAccount,
    required DeviceToRegister deviceToRegister,
  }) {
    session.token = userAccount.authToken;
    return deviceApiClient.registerDevice(
      userAccount.hospital!.authData.baseUrl,
      deviceToRegister,
    );
  }
}
