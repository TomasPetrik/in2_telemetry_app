import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/contracts/logs/logs_contract.dart';
import 'package:scalesoft_app/api/contracts/user/current_user_info_contract.dart';
import 'package:scalesoft_app/api/interceptors/token_interceptor.dart';
import 'package:scalesoft_app/configuration/hospitals_configuration.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';

@singleton
class AccountRepository {
  final AccountApiClient accountApiClient;
  final UserCubit session;

  AccountRepository(this.accountApiClient, this.session);

  Future<CurrentUserInfoContract> loadUserInfo({
    AuthToken? authToken,
    int? userId,
    required String apiUrl,
  }) {
    TokenInterceptor.userId = userId;

    final authHeader =
        authToken == null ? null : 'Bearer ${authToken.accessToken}';
    return accountApiClient.loadUserInfo(authHeader, apiUrl);
  }

  Future<void> sendUserAppReports({
    required int userId,
    required LogsContract reportRequest,
  }) {
    TokenInterceptor.userId = userId;

    return accountApiClient.sendUserAppReports(
      session.state.currentUser.hospital.authData.baseUrl,
      reportRequest,
      HospitalsConfiguration.logEndpointSecret,
    );
  }
}
