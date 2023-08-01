import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/model/auth_token.dart';
import 'package:scalesoft_app/api/model/report/report_request.dart';
import 'package:scalesoft_app/api/model/user_info.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class AccountRepository {
  final AccountApiClient accountApiClient;
  final Session session;

  AccountRepository(this.accountApiClient, this.session);

  Future<UserInfo> loadUserInfo({
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
    );
  }
}
