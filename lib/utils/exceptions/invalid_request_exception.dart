import 'package:dio/dio.dart';

class InvalidRequestException extends DioException {
  InvalidRequestException() : super(requestOptions: RequestOptions(path: ''));
}
