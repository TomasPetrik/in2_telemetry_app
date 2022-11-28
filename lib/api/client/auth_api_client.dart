
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/dto/refresh_token_request.dart';
import 'package:scalesoft_app/api/dto/refresh_token_response.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

part 'auth_api_client.g.dart';

@RestApi(baseUrl: 'https://in2-win-auth.devscale.cz')
@injectable
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(@Named(Constants.privateDioName) Dio dio) = _AuthApiClient;

  @POST('/connect/token')
  Future<RefreshTokenResponse> refreshToken(@Body() RefreshTokenRequest request);
}
