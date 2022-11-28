import 'dart:io';

import 'package:dio/dio.dart';

class NoInternetException extends DioError {
  NoInternetException() : super(requestOptions: RequestOptions(path: ''));

  static bool isNoInternet(DioError e) =>
      [DioErrorType.connectTimeout, DioErrorType.receiveTimeout, DioErrorType.sendTimeout].contains(e.type) ||
      (e.type == DioErrorType.other && (e.error is HttpException || e.error is SocketException));
}
