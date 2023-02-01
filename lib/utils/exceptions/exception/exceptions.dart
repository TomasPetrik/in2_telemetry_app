import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/exceptions/exception/forbidden_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/internal_server_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/invalid_request_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/no_internet_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/not_found_exception.dart';
import 'package:scalesoft_app/utils/exceptions/exception/unauthorized_exception.dart';

void processException(
  Exception exception,
  Emitter emit,
  Function(String) errorState,
) {
  if (exception is InvalidRequestException) {
    getIt<AuthBloc>().add(
      Authenticate(
        hospital: getIt<Session>().userAccount!.hospital!,
      ),
    );
    emit(errorState('Invalid request.'));
  } else if (exception is UnauthorizedException) {
    emit(errorState('Unable to authenticate the user.'));
  } else if (exception is ForbiddenException) {
    emit(errorState('User account locked out.'));
  } else if (exception is NotFoundException) {
    emit(errorState('User or other data not found.'));
  } else if (exception is InternalServerException) {
    emit(errorState('Internal server error.'));
  } else if (exception is NoInternetException) {
    emit(errorState('No internet.'));
  } else {
    emit(errorState('Unknown error.'));
  }
}
