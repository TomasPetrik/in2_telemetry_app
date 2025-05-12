import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/client/account_api_client.dart';
import 'package:scalesoft_app/api/client/auth_api_client.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/configuration/hospitals_configuration.dart';
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
class TokenInterceptor extends QueuedInterceptor {
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
    final user =
        userCubit.state.allUsers.firstWhereOrNull((x) => x.id == userId);

    // TODO: Remove temporary hack for avoiding infinite recursion.
    if (options.headers.containsKey(HttpHeaders.authorizationHeader) ||
        options.path.endsWith('token') ||
        user == null) {
      return handler.next(options);
    }

    AuthToken? refreshedToken;

    if (user.authToken.isExpiring()) {
      refreshedToken = await performTokenRefresh(user);
    }

    final accessToken = (refreshedToken ?? user.authToken).accessToken;

    options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    UserModel? user;

    if (err.requestOptions.headers
        .containsKey(HttpHeaders.authorizationHeader)) {
      final originalToken = err
          .requestOptions.headers[HttpHeaders.authorizationHeader]
          .toString()
          .split(' ')[1];
      user = await userDbProvider.getByAccessToken(originalToken);
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
        // If the error is a result of trying to refresh an access token, fail.
        final refreshTokenValue = err.requestOptions.data?['refresh_token'];
        if (refreshTokenValue != null) {
          getIt<SyncBloc>().add(
            SyncEvent.userSessionExpired(refreshTokenValue),
          );
        } else if (user != null) {
          // Otherwise, try to refresh the access token and retry the request.
          final newToken = (await performTokenRefresh(user))?.accessToken;
          if (newToken == null) {
            return handler.next(err);
          }
          final authHeaderValue = 'Bearer $newToken';

          final headers = err.requestOptions.headers;
          headers.update(
            HttpHeaders.authorizationHeader,
            (_) => authHeaderValue,
            ifAbsent: () => authHeaderValue,
          );

          final response = await Dio().request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options:
                Options(method: err.requestOptions.method, headers: headers),
          );
          return handler.resolve(response);
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

  Future<AuthToken?> performTokenRefresh(UserModel user) async {
    // Don't refresh tokens of represented people - that would lead to different
    // Tokens between a user and their represented people
    final parent = userCubit.state.allUsers
            .firstWhereOrNull((x) => x.id == user.parentId) ??
        user;

    final refreshToken = parent.authToken.refreshToken;
    final tokenUrl = parent.hospital.authData.tokenUrl;
    try {
      final response = await getIt<AuthApiClient>().refreshToken(
        tokenUrl,
        'refresh_token',
        refreshToken,
        HospitalsConfiguration.clientId,
        parent.hospital.clientSecret,
      );

      final newToken = AuthToken(
        response.accessToken,
        response.refreshToken,
        DateTime.now().add(Duration(seconds: response.expiresIn)),
      );

      final newUserPermissions =
          JwtParser(jwtToken: newToken.accessToken).getUserPermissions();

      final changeFuture = userCubit.waitForChange(
        (x) =>
            x.id == parent.id &&
            x.authToken.accessToken == newToken.accessToken,
      );
      await userDbProvider.updateAuthParameters(
        parent.id,
        newToken,
        newUserPermissions,
      );

      // Wait for the change to propagate.
      await changeFuture;

      return newToken;
    } catch (e, trace) {
      debugPrintStack(
        label: "Failed to refresh token: $e",
        stackTrace: trace,
      );
      userDbProvider.setExpiredByRefreshToken(refreshToken);
      return null;
    }
  }
}
