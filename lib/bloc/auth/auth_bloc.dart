import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/repository/account_repository.dart';
import 'package:scalesoft_app/services/auth_service.dart';
import 'package:scalesoft_app/storage/storage.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final AccountRepository _accountService;
  final Storage _storage;

  AuthBloc(this._authService, this._accountService, this._storage) : super(const Unauthenticated()) {
    on<Authenticate>(_onAuthenticate);
    on<VerifyUser>(_verifyUser);
    on<LogoutUser>(_logoutUser);
  }

  Future<void> _onAuthenticate(
    Authenticate event,
    Emitter<AuthState> emit,
  ) async {
    emit(const Authenticating());

    try {
      final tokenResponse = await _authService.authorize(
        Uri.parse(Constants.issuer),
        Constants.clientId,
        Constants.scopes,
        Constants.redirectUrl,
        Constants.clientSecret,
        Constants.authorizationEndpoint,
        Constants.tokenEndpoint,
        Constants.endSessionEndpoint,
      );

      if (tokenResponse != null) {
        _storage.token = AuthToken(
          accessToken: tokenResponse.credentials.accessToken,
          refreshToken: tokenResponse.credentials.refreshToken!,
          accessTokenExpires: tokenResponse.credentials.expiration!,
        );
        emit(Authenticated(credentials: tokenResponse.credentials));
      } else {
        emit(Unauthenticated(error: Exception('Authentication failed')));
      }
    } on Exception catch (e) {
      emit(Unauthenticated(error: e));
    }
  }

  Future<void> _verifyUser(
    VerifyUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final userInfo = await _accountService.loadUserInfo();
      await _storage.setAuthToken(
        userInfo.currentUser.muid,
        _storage.token!,
      );

      _storage.userInfo = userInfo;

      emit(UserVerified(userInfo: userInfo));
    } on Exception catch (e) {
      _storage.token = null;
      emit(Unauthenticated(error: e));
    }
  }

  Future<void> _logoutUser(
    LogoutUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _storage.removeTokens(_storage.userInfo!.currentUser.muid);
      _storage.token = null;
      _storage.userInfo = null;

      emit(const LogoutSuccess());
    } on Exception catch (e) {
      emit(LogoutFailed(error: e));
    }
  }
}
