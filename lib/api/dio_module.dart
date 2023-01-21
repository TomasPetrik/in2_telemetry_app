import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

@module
abstract class DioModule {
  @Named(Constants.privateDioName)
  @singleton
  Dio get privateDio => Dio(
        BaseOptions(
          baseUrl: Constants.baseUrl,
          contentType: 'application/json',
          connectTimeout: 30000,
          receiveTimeout: 30000,
        ),
      )..interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: true,
            error: true,
            compact: false,
            maxWidth: 120,
          ),
        );
  // ..interceptors.add(HttpErrorInterceptor());
}
