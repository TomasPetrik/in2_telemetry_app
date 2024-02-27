import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oauth2/oauth2.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticating() = _Authenticating;
  const factory AuthState.handlingResponse() = _HandlingResponse;
  const factory AuthState.cancelled() = _Cancelled;
  const factory AuthState.authenticated({required Credentials credentials}) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.userVerified({required UserAccount userAccount}) = _UserVerified;
  const factory AuthState.inactiveUserRemoved({
    required UserAccount userAccount,
  }) = _InactiveUserRemoved;
  const factory AuthState.logoutSuccess() = _LogoutSuccess;
  const factory AuthState.logoutFailed({required Exception error}) = _LogoutFailed;
  const factory AuthState.lastSessionRestored({UserAccount? userAccount}) = _LastSessionRestored;
  const factory AuthState.error(String message) = _Error;
  const factory AuthState.errorLoadData() = _ErrorLoadData;
}
