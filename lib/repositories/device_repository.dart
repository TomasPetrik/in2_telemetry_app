import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/device_api_client.dart';
import 'package:scalesoft_app/api/contracts/device/device_create_contract.dart';
import 'package:scalesoft_app/api/contracts/device/device_instruction_contract.dart';
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
    final user = session.getUser(userId);

    return await deviceApiClient.getDeviceModels(
      user.hospital.authData.baseUrl,
    );
  }

  Future<List<DeviceInstructionContract>> getDeviceInstructions({
    required int userId
  }) async {
    TokenInterceptor.userId = userId;
    final user = session.getUser(userId);

    return await deviceApiClient.getDeviceInstructions(
      user.hospital.authData.baseUrl
    );
  }

  Future<void> registerDevice({
    required int userId,
    required DeviceCreateContract deviceToRegister,
  }) async {
    TokenInterceptor.userId = userId;
    final user = session.getUser(userId);

    return await deviceApiClient.registerDevice(
      user.hospital.authData.baseUrl,
      deviceToRegister,
    );
  }
}
