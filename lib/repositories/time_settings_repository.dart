import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/time_settings_api_client.dart';
import 'package:scalesoft_app/api/dto/settings/time_setting.dart';
import 'package:scalesoft_app/api/dto/settings/time_settings.dart';
import 'package:scalesoft_app/api/dto/template_time_set.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class TimeSettingsRepository {
  final TimeSettingsApiClient timeSettingsApiClient;
  final Session session;

  TimeSettingsRepository(this.timeSettingsApiClient, this.session);

  Future<TemplateTimeSet> loadPlanTemplate({
    required UserAccount userAccount,
  }) =>
      timeSettingsApiClient.loadPlanTemplate(
        userAccount.hospital!.authData.baseUrl,
      );

  Future<List<TimeSetting>> loadTimeSettings({
    required UserAccount userAccount,
  }) =>
      timeSettingsApiClient.loadTimeSettings(
        userAccount.hospital!.authData.baseUrl,
      );

  Future<void> updateTimeSettings({
    required UserAccount userAccount,
    required TimeSettings timeSettings,
  }) =>
      timeSettingsApiClient.updateTimeSettings(
        userAccount.hospital!.authData.baseUrl,
        timeSettings,
      );
}
