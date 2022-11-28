import 'package:dio/dio.dart';

class ForbiddenException extends DioError {
  ForbiddenException() : super(requestOptions: RequestOptions(path: ''));
}
