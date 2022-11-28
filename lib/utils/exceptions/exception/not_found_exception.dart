import 'package:dio/dio.dart';

class NotFoundException extends DioError {
  NotFoundException() : super(requestOptions: RequestOptions(path: ''));
}
