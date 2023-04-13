import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/model/user_info.dart';

@singleton
class AccountRepository {
  final AccountApiClient accountApiClient;

  AccountRepository(this.accountApiClient);

  Future<UserInfo> loadUserInfo() => accountApiClient.loadUserInfo();
}
