import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/contracts/user/current_user_info_contract.dart';
import 'package:scalesoft_app/config.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class AccountRepository {
  final AccountApiClient accountApiClient;
  final Session session;

  AccountRepository(this.accountApiClient, this.session);

  Future<CurrentUserInfoContract> loadUserInfo({
    required AuthToken authToken,
    required String apiUrl,
  }) {
    session.token = authToken;
    return accountApiClient.loadUserInfo(apiUrl);
  }

  Future<void> sendUserAppReports({
    required UserAccount userAccount,
    required ReportRequest reportRequest,
  }) {
    session.token = userAccount.authToken;
    return accountApiClient.sendUserAppReports(
      userAccount.hospital!.authData.baseUrl,
      reportRequest,
      Config.value.logEndpointSecret,
    );
  }
}
