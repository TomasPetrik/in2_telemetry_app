import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:oauth2/oauth2.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/services/auth_service.dart';
import 'package:scalesoft_app/storage/storage.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final AccountRepository _accountService;
  final Storage _storage;
  AuthorizationCodeGrant? grant;

  AuthBloc(this._authService, this._accountService, this._storage) : super(const AuthState.unauthenticated()) {
    on<Authenticate>(_onAuthenticate);
    on<HandleAuthResponse>(_onHandleAuthResponse);
    on<VerifyUser>(_verifyUser);
    on<LogoutUser>(_logoutUser);
    on<CancelAuth>(_cancelAuth);
  }

  Future<void> _onAuthenticate(
    Authenticate event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.authenticating());

    try {
      grant = _authService.getAuthGrant(
        Uri.parse(Constants.issuer),
        Constants.clientId,
        Constants.clientSecret,
        Constants.authorizationEndpoint,
        Constants.tokenEndpoint,
        Constants.endSessionEndpoint,
      );

      emit(
        AuthState.openAuthReqest(
          authUri: grant!.getAuthorizationUrl(
            Uri.parse(Constants.redirectUrl),
            scopes: Constants.scopes,
            state: DateTime.now().toString(),
          ),
        ),
      );
    } on Exception catch (e) {
      emit(AuthState.unauthenticated(error: e));
    }
  }

  Future<void> _onHandleAuthResponse(
    HandleAuthResponse event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final tokenResponse = await grant!.handleAuthorizationResponse(
        event.authRespUri.queryParameters,
      );

      _storage.token = AuthToken(
        accessToken: tokenResponse.credentials.accessToken,
        refreshToken: tokenResponse.credentials.refreshToken!,
        accessTokenExpires: tokenResponse.credentials.expiration!,
      );
      emit(AuthState.authenticated(credentials: tokenResponse.credentials));
    } on Exception catch (e) {
      emit(AuthState.unauthenticated(error: e));
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

      emit(AuthState.userVerified(userInfo: userInfo));
    } on Exception catch (e) {
      _storage.token = null;
      emit(AuthState.unauthenticated(error: e));
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

      emit(const AuthState.logoutSuccess());
    } on Exception catch (e) {
      emit(AuthState.logoutFailed(error: e));
    }
  }

  Future<void> _cancelAuth(
    CancelAuth event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.cancelled());
  }
}
