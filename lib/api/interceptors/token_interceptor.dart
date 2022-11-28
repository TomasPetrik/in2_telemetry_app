import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/client/auth_api_client.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/api/dto/refresh_token_request.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/storage.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/utils/exceptions/exception/forbidden_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/internal_server_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/invalid_request_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/no_internet_exception.dart';

@injectable
class TokenInterceptor extends Interceptor {
  final Storage storage;
  final AccountApiClient accountApiClient;

  TokenInterceptor(
    this.storage,
    this.accountApiClient,
  );

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = storage.token;
    if (accessToken == null || accessToken.isExpired()) {
      refreshToken();
    }

    if (storage.token != null) {
      options.headers.putIfAbsent(
        HttpHeaders.authorizationHeader,
        () => 'Bearer ${storage.token!.accessToken}',
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
          final response = await getIt<Dio>(instanceName: Constants.privateDioName).fetch(err.requestOptions);
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
      final userId = storage.userInfo?.currentUser.muid;

      if (userId != null) {
        final refreshToken = await storage.getRefreshToken(userId);
        if (refreshToken != null) {
          final request = RefreshTokenRequest(userId: userId, refreshToken: refreshToken);
          final response = await getIt<AuthApiClient>().refreshToken(request);
          await storage.setAuthToken(
            userId,
            AuthToken(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
              accessTokenExpires: DateTime.now().add(const Duration(seconds: 3600)),
            ),
          );
        }
      }
    } catch (e) {
      return;
    }
  }
}
