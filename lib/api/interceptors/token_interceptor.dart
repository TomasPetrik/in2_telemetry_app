import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/client/auth_api_client.dart';
import 'package:scalesoft_app/api/model/auth_token.dart';
import 'package:scalesoft_app/api/model/report/report.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/config.dart';
import 'package:scalesoft_app/parsers/jwt_parser.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/utils/exceptions/invalid_request_exception.dart';

@injectable
class TokenInterceptor extends Interceptor {
  final Session session;
  final AccountApiClient accountApiClient;
  final AccountDbProvider accountDbProvider;
  final ReportService reportService;

  TokenInterceptor(
    this.session,
    this.accountApiClient,
    this.accountDbProvider,
    this.reportService,
  );

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (session.token?.isExpiring() ?? false) {
      await refreshToken(session.token!.accessToken);
    }

    final accessToken = session.token?.accessToken;

    if (!options.headers.containsKey(HttpHeaders.authorizationHeader) &&
        accessToken != null) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.requestOptions.headers
        .containsKey(HttpHeaders.authorizationHeader)) {
      final originalToken = err
          .requestOptions.headers[HttpHeaders.authorizationHeader]
          .toString()
          .split(' ')[1];
      final userAccount = accountDbProvider.getByToken(originalToken);
      if (userAccount != null) {
        reportService.trackEvent(
          userAccount: userAccount,
          severity: Severity.error,
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

  Future<AuthToken?> refreshToken(String originalToken) async {
    final userAccount = accountDbProvider.getByToken(originalToken);

    if (userAccount == null) return null;

    final refreshToken = userAccount.authToken!.refreshToken;
    final tokenUrl = userAccount.hospital!.authData.tokenUrl;

    session.token = userAccount.authToken;
    // Avoid calling this method recursively when refreshing the token...
    session.token!.accessTokenExpires =
        DateTime.now().add(const Duration(minutes: 10));

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
      DateTime.now().add(const Duration(seconds: 3600)),
    );

    final newUserPermissions =
        JwtParser(jwtToken: newToken.accessToken).getUserPermissions();

    userAccount.authToken = newToken;
    userAccount.userPermissions = newUserPermissions;
    if (userAccount.representedPeople != null) {
      for (final representedPerson in userAccount.representedPeople!) {
        representedPerson.authToken = newToken;
        representedPerson.userPermissions = newUserPermissions;
      }
    }
    await accountDbProvider.save(userAccount);

    return newToken;
  }
}
