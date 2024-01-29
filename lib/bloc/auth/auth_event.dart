import 'package:equatable/equatable.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/model/user_account.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthFromColdStart extends AuthEvent {
  final Uri authUri;
  const AuthFromColdStart({
    required this.authUri,
  });

  @override
  List<Object?> get props => [authUri];
}

class Authenticate extends AuthEvent {
  final Hospital hospital;
  const Authenticate({
    required this.hospital,
  });

  @override
  List<Object?> get props => [hospital];
}

class HandleAuthResponse extends AuthEvent {
  const HandleAuthResponse();

  @override
  List<Object?> get props => [];
}

class CancelAuth extends AuthEvent {
  const CancelAuth();

  @override
  List<Object?> get props => [];
}

class VerifyUser extends AuthEvent {
  const VerifyUser();

  @override
  List<Object?> get props => [];
}

class LogoutUser extends AuthEvent {
  final UserAccount userAccount;

  const LogoutUser({
    required this.userAccount,
  });

  @override
  List<Object?> get props => [userAccount];
}

class ErrorLoadDataEvent extends AuthEvent {
  const ErrorLoadDataEvent();

  @override
  List<Object?> get props => [];
}
