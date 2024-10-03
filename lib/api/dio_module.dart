import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';

@module
abstract class DioModule {
  @Named(ConfigurationConstants.privateDioName)
  @singleton
  Dio get privateDio => Dio(
        BaseOptions(
          contentType: 'application/json',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      )..interceptors.addAll([
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
            compact: false,
            maxWidth: 120,
          ),
          // HttpErrorInterceptor(),
        ]);
  @Named(ConfigurationConstants.authDioName)
  @singleton
  Dio get authDio => Dio(
    BaseOptions(
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.addAll([
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: false,
      maxWidth: 120,
    ),
  ]);
}
