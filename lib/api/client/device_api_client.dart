import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/contracts/device/device_instruction_contract.dart';
import 'package:scalesoft_app/api/contracts/device/device_prototype_contract.dart';
import 'package:scalesoft_app/api/contracts/device/device_create_contract.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';

part 'device_api_client.g.dart';

@RestApi(baseUrl: '')
@injectable
abstract class DeviceApiClient {
  @factoryMethod
  factory DeviceApiClient(@Named(ConfigurationConstants.privateDioName) Dio dio) =
      _DeviceApiClient;

  @POST('{apiUrl}/device')
  Future<void> registerDevice(
    @Path('apiUrl') String apiUrl,
    @Body() DeviceCreateContract deviceToRegister,
  );

  @GET('{apiUrl}/device/models')
  Future<List<DevicePrototypeContract>> getDeviceModels(@Path('apiUrl') String apiUrl);

  @GET('{apiUrl}/device/model/instruction')
  Future<List<DeviceInstructionContract>> getDeviceInstructions(@Path('apiUrl') String apiUrl);
}
