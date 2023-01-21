import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/client/auth_api_client.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/utils/exceptions/exception/forbidden_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/internal_server_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/invalid_request_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/no_internet_exception.dart';

@injectable
class TokenInterceptor extends Interceptor {
  final Session session;
  final AccountApiClient accountApiClient;
  final Dio dio;

  TokenInterceptor(
    this.session,
    this.accountApiClient,
    @Named(Constants.privateDioName) this.dio,
  );

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = session.token;
    if (accessToken == null || accessToken.isExpired()) {
      refreshToken();
    }

    if (session.token != null) {
      options.headers.putIfAbsent(
        HttpHeaders.authorizationHeader,
        () => 'Bearer ${session.token!.accessToken}',
      );
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 400:
        throw InvalidRequestException();
      case 401:
        refreshToken().then((value) async {
          err.requestOptions.headers.remove(HttpHeaders.authorizationHeader);
          final response =
              await getIt<Dio>(instanceName: Constants.privateDioName)
                  .fetch(err.requestOptions);
          handler.resolve(response);
        });
        return;
      case 403:
        throw ForbiddenException();
      case 500:
        throw InternalServerException();
      default:
        if (NoInternetException.isNoInternet(err)) throw NoInternetException();
        throw Exception();
    }
  }

  Future<void> refreshToken() async {
    try {
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
        await session.setAuthToken(
          userId,
          AuthToken(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            accessTokenExpires:
                DateTime.now().add(const Duration(seconds: 3600)),
          ),
        );
      }
    } catch (e) {
      return;
    }
  }
}
