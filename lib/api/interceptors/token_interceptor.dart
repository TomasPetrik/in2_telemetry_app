import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/client/auth_api_client.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/utils/exceptions/exception/invalid_request_exception.dart';

@injectable
class TokenInterceptor extends Interceptor {
  final Session session;
  final AccountApiClient accountApiClient;

  TokenInterceptor(
    this.session,
    this.accountApiClient,
  );

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = session.token;

    /*
    if (accessToken == null || accessToken.isExpired()) {
      accessToken = await refreshToken();
    }
    */

    if (accessToken != null) {
      options.headers[HttpHeaders.authorizationHeader] =
          'Bearer ${session.token!.accessToken}';
    }

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    switch (err.response?.statusCode) {
      case 400:
        final refreshToken = err.requestOptions.data["refresh_token"];
        getIt<SyncBloc>().add(
          SyncEvent.userSessionExpired(refreshToken),
        );
        throw InvalidRequestException();
      case 401:
        final originReqOpt = err.requestOptions;

        final newAuthToken = await refreshToken();
        if (newAuthToken != null) {
          originReqOpt.headers[HttpHeaders.authorizationHeader] =
              'Bearer ${session.token!.accessToken}';
          final dio = getIt<Dio>(instanceName: Constants.privateDioName);
          final response = await dio.fetch(originReqOpt);
          handler.resolve(response);
        } else {
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

  Future<AuthToken?> refreshToken() async {
    final userId = session.userAccount?.user.muid;
    final refreshToken = session.userAccount?.authToken?.refreshToken;
    final tokenUrl = session.userAccount?.hospital?.authData.tokenUrl;

    if (userId != null && refreshToken != null && tokenUrl != null) {
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

      session.token = newToken;

      return newToken;
    }

    return null;
  }
}
