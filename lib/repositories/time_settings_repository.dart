import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/time_settings_api_client.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_template_contract.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_setting_contract.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_settings_update_contract.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';

@singleton
class TimeSettingsRepository {
  final TimeSettingsApiClient timeSettingsApiClient;
  final UserCubit session;

  TimeSettingsRepository(this.timeSettingsApiClient, this.session);

  Future<CarePlanTemplateContract> loadPlanTemplate({
    required int userId,
  }) async {
    TokenInterceptor.userId = userId;
    final user = session.getUser(userId);

    return await timeSettingsApiClient.loadPlanTemplate(
      user.hospital.authData.baseUrl,
    );
  }

  Future<List<TimeSettingContract>> loadTimeSettings(
    AuthToken authToken,
    String apiUrl,
      List<String> userMuids,
  ) {
    return timeSettingsApiClient.loadTimeSettings(apiUrl, 'Bearer ${authToken.accessToken}', userMuids);
  }

  Future<void> updateTimeSettings({
    required int userId,
    required TimeSettingsUpdateContract timeSettings,
  }) async {
    TokenInterceptor.userId = userId;
    final user = session.getUser(userId);

    return timeSettingsApiClient.updateTimeSettings(
      user.hospital.authData.baseUrl,
      timeSettings,
    );
  }
}
