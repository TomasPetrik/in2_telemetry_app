import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/model/report/report_request.dart';
import 'package:scalesoft_app/api/model/user_info.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';

part 'account_api_client.g.dart';

@RestApi()
@injectable
abstract class AccountApiClient {
  @factoryMethod
  factory AccountApiClient(@Named(ConfigurationConstants.privateDioName) Dio dio) =
      _AccountApiClient;

  @GET('{apiUrl}/user/me')
  Future<UserInfo> loadUserInfo(
    @Path('apiUrl') String apiUrl,
  );

  @POST('{apiUrl}/user/me/app-logs')
  Future<void> sendUserAppReports(
    @Path('apiUrl') String apiUrl,
    @Body() ReportRequest reportRequest,
  );
}
