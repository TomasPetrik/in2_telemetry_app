import 'package:dio/dio.dart';

class InvalidRequestException extends DioError {
  InvalidRequestException() : super(requestOptions: RequestOptions(path: ''));
}
