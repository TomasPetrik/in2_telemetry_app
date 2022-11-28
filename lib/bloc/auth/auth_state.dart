import 'package:equatable/equatable.dart';
import 'package:oauth2/oauth2.dart';
import 'package:scalesoft_app/api/dto/user_info.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class Authenticating extends AuthState {
  const Authenticating();

  @override
  List<Object?> get props => [];
}

class Unauthenticated extends AuthState {
  final Exception? error;

  const Unauthenticated({this.error});

  @override
  List<Object?> get props => [error];
}

class Authenticated extends AuthState {
  final Credentials? credentials;

  const Authenticated({this.credentials});

  @override
  List<Object?> get props => [credentials];
}

class UserVerified extends AuthState {
  final UserInfo? userInfo;

  const UserVerified({this.userInfo});

  @override
  List<Object?> get props => [userInfo];
}

class LogoutSuccess extends AuthState {
  const LogoutSuccess();

  @override
  List<Object?> get props => [];
}

class LogoutFailed extends AuthState {
  final Exception? error;

  const LogoutFailed({this.error});

  @override
  List<Object?> get props => [error];
}
