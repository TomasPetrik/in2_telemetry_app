import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/contracts/logs/logs_contract.dart';
import 'package:scalesoft_app/api/contracts/user/current_user_info_contract.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';

part 'account_api_client.g.dart';

@RestApi()
@injectable
abstract class AccountApiClient {
  @factoryMethod
  factory AccountApiClient(@Named(ConfigurationConstants.privateDioName) Dio dio) = _AccountApiClient;

  @GET('{apiUrl}/user/me')
  Future<CurrentUserInfoContract> loadUserInfo(
    @Header(HttpHeaders.authorizationHeader) String authHeader,
    @Path('apiUrl') String apiUrl,
  );

  @POST('{apiUrl}/user/me/app-logs')
  Future<void> sendUserAppReports(
    @Path('apiUrl') String apiUrl,
    @Body() LogsContract reportRequest,
    @Header("X-Custom-Authentication") String authHeader,
  );
}
