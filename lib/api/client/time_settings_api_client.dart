import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_template_contract.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_setting_contract.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_settings_update_contract.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';

part 'time_settings_api_client.g.dart';

@RestApi(baseUrl: '')
@injectable
abstract class TimeSettingsApiClient {
  @factoryMethod
  factory TimeSettingsApiClient(@Named(ConfigurationConstants.privateDioName) Dio dio) = _TimeSettingsApiClient;

  @GET('{apiUrl}/care-plan/template')
  Future<CarePlanTemplateContract> loadPlanTemplate(
    @Path('apiUrl') String apiUrl,
  );

  @GET('{apiUrl}/patient/time-settings')
  Future<List<TimeSettingContract>> loadTimeSettings(
    @Path('apiUrl') String apiUrl,
    @Header(HttpHeaders.authorizationHeader) String authHeader,
    @Query('userMuids') List<String> userMuids,
  );

  @POST('{apiUrl}/patient/time-settings')
  Future<void> updateTimeSettings(
    @Path('apiUrl') String apiUrl,
    @Body() TimeSettingsUpdateContract timeSettings,
  );
}
