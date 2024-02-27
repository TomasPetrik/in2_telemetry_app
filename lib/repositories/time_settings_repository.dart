import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/time_settings_api_client.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class TimeSettingsRepository {
  final TimeSettingsApiClient timeSettingsApiClient;
  final Session session;

  TimeSettingsRepository(this.timeSettingsApiClient, this.session);

  Future<TemplateTimeSet> loadPlanTemplate({
    required UserAccount userAccount,
  }) {
    session.token = userAccount.authToken;
    return timeSettingsApiClient.loadPlanTemplate(
      userAccount.hospital!.authData.baseUrl,
    );
  }

  Future<List<TimeSetting>> loadTimeSettings({
    required UserAccount userAccount,
  }) {
    session.token = userAccount.authToken;
    return timeSettingsApiClient.loadTimeSettings(
      userAccount.hospital!.authData.baseUrl,
    );
  }

  Future<void> updateTimeSettings({
    required UserAccount userAccount,
    required TimeSettings timeSettings,
  }) {
    session.token = userAccount.authToken;
    return timeSettingsApiClient.updateTimeSettings(
      userAccount.hospital!.authData.baseUrl,
      timeSettings,
    );
  }
}
