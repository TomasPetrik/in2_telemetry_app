import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/contracts/logs/logs_contract.dart';
import 'package:scalesoft_app/api/contracts/user/current_user_info_contract.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/config.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';

@singleton
class AccountRepository {
  final AccountApiClient accountApiClient;
  final UserCubit session;

  AccountRepository(this.accountApiClient, this.session);

  Future<CurrentUserInfoContract> loadUserInfo({
    required AuthToken authToken,
    required String apiUrl,
  }) {
    return accountApiClient.loadUserInfo('Bearer ${authToken.accessToken}', apiUrl);
  }

  Future<void> sendUserAppReports({
    required int userId,
    required LogsContract reportRequest,
  }) {
    TokenInterceptor.userId = userId;

    return accountApiClient.sendUserAppReports(
      session.state.currentUser.hospital.authData.baseUrl,
      reportRequest,
      Config.value.logEndpointSecret,
    );
  }
}
