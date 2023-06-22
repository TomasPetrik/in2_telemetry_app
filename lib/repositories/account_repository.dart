import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/model/auth_token.dart';
import 'package:scalesoft_app/api/model/user_info.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class AccountRepository {
  final AccountApiClient accountApiClient;
  final Session session;

  AccountRepository(this.accountApiClient, this.session);

  Future<UserInfo> loadUserInfo({
    required AuthToken authToken,
  }) {
    session.token = authToken;
    return accountApiClient.loadUserInfo();
  }
}
