import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oauth2/oauth2.dart';
import 'package:scalesoft_app/model/user_account.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticating() = _Authenticating;
  const factory AuthState.cancelled() = _Cancelled;
  const factory AuthState.authenticated({Credentials? credentials}) = _Authenticated;
  const factory AuthState.unauthenticated({Exception? error}) = _Unauthenticated;
  const factory AuthState.openAuthReqest({required Uri authUri}) = _OpenAuthReqest;
  const factory AuthState.userVerified({required UserAccount userAccount}) = _UserVerified;
  const factory AuthState.logoutSuccess() = _LogoutSuccess;
  const factory AuthState.logoutFailed({Exception? error}) = _LogoutFailed;
  const factory AuthState.lastSessionRestored({UserAccount? userAccount}) = _LastSessionRestored;
}
