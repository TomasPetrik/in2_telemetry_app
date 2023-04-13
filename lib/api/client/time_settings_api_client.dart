import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/model/settings/time_setting.dart';
import 'package:scalesoft_app/api/model/settings/time_settings.dart';
import 'package:scalesoft_app/api/model/template_time_set.dart';
import 'package:scalesoft_app/utils/constants.dart';

part 'time_settings_api_client.g.dart';

@RestApi(baseUrl: '')
@injectable
abstract class TimeSettingsApiClient {
  @factoryMethod
  factory TimeSettingsApiClient(@Named(Constants.privateDioName) Dio dio) =
      _TimeSettingsApiClient;

  @GET('{apiUrl}/care-plan/template')
  Future<TemplateTimeSet> loadPlanTemplate(
    @Path('apiUrl') String apiUrl,
  );

  @GET('{apiUrl}/patient/time-settings')
  Future<List<TimeSetting>> loadTimeSettings(
    @Path('apiUrl') String apiUrl,
  );

  @POST('{apiUrl}/patient/time-settings')
  Future<void> updateTimeSettings(
    @Path('apiUrl') String apiUrl,
    @Body() TimeSettings timeSettings,
  );
}
