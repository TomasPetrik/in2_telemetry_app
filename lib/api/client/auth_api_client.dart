import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/dto/refresh_token_response.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

part 'auth_api_client.g.dart';

@RestApi(baseUrl: '')
@injectable
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(@Named(Constants.privateDioName) Dio dio) =
      _AuthApiClient;

  @POST('{tokenUrl}')
  @FormUrlEncoded()
  Future<RefreshTokenResponse> refreshToken(
    @Path('tokenUrl') String tokenUrl,
    @Field('grant_type') String grantType,
    @Field('refresh_token') String refreshToken,
    @Field('client_id') String clientId,
    @Field('client_secret') String clientSecret,
  );
}
