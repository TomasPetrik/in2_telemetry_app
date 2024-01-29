import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/model/device_model.dart';
import 'package:scalesoft_app/api/model/device_to_register.dart';
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
    @Body() DeviceToRegister deviceToRegister,
  );

  @GET('{apiUrl}/device/models')
  Future<List<DeviceModel>> getDeviceModels(@Path('apiUrl') String apiUrl);
}
