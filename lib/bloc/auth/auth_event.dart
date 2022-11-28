import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class Authenticate extends AuthEvent {
  const Authenticate();

  @override
  List<Object?> get props => [];
}

class VerifyUser extends AuthEvent {
  const VerifyUser();

  @override
  List<Object?> get props => [];
}


class LogoutUser extends AuthEvent {
  const LogoutUser();

  @override
  List<Object?> get props => [];
}


