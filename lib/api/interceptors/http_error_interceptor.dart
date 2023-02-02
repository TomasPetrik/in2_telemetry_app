import 'package:dio/dio.dart';
import 'package:scalesoft_app/utils/exceptions/exception/forbidden_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/internal_server_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/invalid_request_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/no_internet_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/not_found_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/unauthorized_exception.dart';

class HttpErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 400:
        throw InvalidRequestException();
      case 401:
        throw UnauthorizedException();
      case 403:
        throw ForbiddenException();
      case 404:
        throw NotFoundException();
      case 500:
        throw InternalServerException();
      default:
        if (NoInternetException.isNoInternet(err)) throw NoInternetException();
        throw Exception();
    }
  }
}
