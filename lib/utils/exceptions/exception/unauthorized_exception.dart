import 'package:dio/dio.dart';

class UnauthorizedException extends DioError {
  UnauthorizedException() : super(requestOptions: RequestOptions(path: ''));
}
