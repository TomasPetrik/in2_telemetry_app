import 'package:dio/dio.dart';

class InternalServerException extends DioError {
  InternalServerException() : super(requestOptions: RequestOptions(path: ''));
}
