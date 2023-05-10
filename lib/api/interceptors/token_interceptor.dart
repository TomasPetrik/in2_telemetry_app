import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/client/auth_api_client.dart';
import 'package:scalesoft_app/api/model/auth_token.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:scalesoft_app/utils/exceptions/invalid_request_exception.dart';

@injectable
class TokenInterceptor extends Interceptor {
  final Session session;
  final AccountApiClient accountApiClient;
  final AccountDbProvider accountDbProvider;

  TokenInterceptor(
    this.session,
    this.accountApiClient,
    this.accountDbProvider,
  );

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = session.token?.accessToken;

    if (!options.headers.containsKey(HttpHeaders.authorizationHeader) &&
        accessToken != null) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    switch (err.response?.statusCode) {
      case 400:
        final refreshToken = err.requestOptions.data['refresh_token'];
        if (refreshToken != null) {
          getIt<SyncBloc>().add(
            SyncEvent.userSessionExpired(refreshToken),
          );
        }
        handler.next(err);
        throw InvalidRequestException();
      case 401:
        try {
          final originalToken = err
              .requestOptions.headers[HttpHeaders.authorizationHeader]
              .toString()
              .split(' ')[1];

          final newAuthToken = await refreshToken(originalToken);
          if (newAuthToken != null) {
            err.requestOptions.headers[HttpHeaders.authorizationHeader] =
                'Bearer ${newAuthToken.accessToken}';
            final dio = getIt<Dio>(instanceName: Constants.privateDioName);
            final response = await dio.fetch(err.requestOptions);
            return handler.resolve(response);
          }
        } catch (_) {
          handler.next(err);
          throw InvalidRequestException();
        }

        return;
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

    final response = await getIt<AuthApiClient>().refreshToken(
      tokenUrl,
      'refresh_token',
      refreshToken,
      Constants.clientId,
      Constants.clientSecret,
    );

    final newToken = AuthToken(
      response.accessToken,
      response.refreshToken,
      DateTime.now().add(const Duration(seconds: 3600)),
    );

    userAccount.authToken = newToken;
    await accountDbProvider.save(userAccount);

    return newToken;
  }
}
