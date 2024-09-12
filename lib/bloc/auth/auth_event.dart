import 'package:equatable/equatable.dart';
import 'package:scalesoft_app/model/hospital.dart';
import 'package:scalesoft_app/model/user_model.dart';

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

class CancelAuth extends AuthEvent {
  const CancelAuth();

  @override
  List<Object?> get props => [];
}

class LogoutUser extends AuthEvent {
  final UserModel userAccount;

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

class AuthCallback extends AuthEvent {
  final Uri authUri;

  const AuthCallback(this.authUri);
}
