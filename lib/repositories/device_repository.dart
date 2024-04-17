import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/device_api_client.dart';
import 'package:scalesoft_app/api/contracts/device/device_create_contract.dart';
import 'package:scalesoft_app/api/contracts/device/device_prototype_contract.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';

@singleton
class DeviceRepository {
  final DeviceApiClient deviceApiClient;
  final UserCubit session;

  DeviceRepository(this.deviceApiClient, this.session);

  Future<List<DevicePrototypeContract>> getDeviceModels({
    required int userId,
  }) async {
    TokenInterceptor.userId = userId;

    return await deviceApiClient.getDeviceModels(
      session.state.currentUser.hospital.authData.baseUrl,
    );
  }

  Future<void> registerDevice({
    required int userId,
    required DeviceCreateContract deviceToRegister,
  }) async {
    TokenInterceptor.userId = userId;

    return await deviceApiClient.registerDevice(
      session.state.currentUser.hospital.authData.baseUrl,
      deviceToRegister,
    );
  }
}
