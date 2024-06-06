import 'dart:io';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/client/auth_api_client.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/config.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/data/providers/user_db_provider.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/parsers/jwt_parser.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/utils/exceptions/invalid_request_exception.dart';

@injectable
class TokenInterceptor extends Interceptor {
  final UserCubit userCubit;
  final AccountApiClient accountApiClient;
  final UserDbProvider userDbProvider;
  final ReportService reportService;

  static int? userId;

  TokenInterceptor(
    this.userCubit,
    this.accountApiClient,
    this.reportService,
    this.userDbProvider,
  );

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final user = userCubit.state.allUsers.firstWhereOrNull((x)=>x.id == userId);

    // TODO: Remove temporary hack for avoiding infinite recursion.
    if (options.headers.containsKey(HttpHeaders.authorizationHeader) || options.path.endsWith('token') || user == null) {
      return handler.next(options);
    }


    if (user.authToken.isExpiring()) {
      await refreshToken(user);
    }

    final accessToken = user.authToken.accessToken;

    options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.requestOptions.headers.containsKey(HttpHeaders.authorizationHeader)) {
      final originalToken = err.requestOptions.headers[HttpHeaders.authorizationHeader].toString().split(' ')[1];
      final user = await userDbProvider.getByAccessToken(originalToken);
      if (user != null) {
        reportService.trackEvent(
          userId: user.id,
          severity: LogSeverity.error,
          message: err.response?.toString() ?? err.error.toString(),
        );
      }
    }

    switch (err.response?.statusCode) {
      case 400:
      case 401:
        final refreshToken = err.requestOptions.data['refresh_token'];
        if (refreshToken != null) {
          getIt<SyncBloc>().add(
            SyncEvent.userSessionExpired(refreshToken),
          );
        }
        handler.next(err);
        throw InvalidRequestException();
      /*
      case 403:
        throw ForbiddenException();
      case 404:
        getIt<AuthBloc>().add(const ErrorLoadDataEvent());
        throw NotFoundException();
      case 500:
        throw InternalServerException();
        */
      default:
        return handler.next(err);
    }
  }

  Future<AuthToken?> refreshToken(UserModel user) async {
    final refreshToken = user.authToken.refreshToken;
    final tokenUrl = user.hospital.authData.tokenUrl;

    final response = await getIt<AuthApiClient>().refreshToken(
      tokenUrl,
      'refresh_token',
      refreshToken,
      Config.value.clientId,
      Config.value.clientSecret,
    );

    final newToken = AuthToken(
      response.accessToken,
      response.refreshToken,
      DateTime.now().add(Duration(seconds: response.expiresIn)),
    );

    final newUserPermissions = JwtParser(jwtToken: newToken.accessToken).getUserPermissions();

    await userDbProvider.updateAuthParameters(user.id, newToken, newUserPermissions);
    // TODO: Wait until change is propagated instead?
    user.authToken.accessToken = newToken.accessToken;

    return newToken;
  }
}
