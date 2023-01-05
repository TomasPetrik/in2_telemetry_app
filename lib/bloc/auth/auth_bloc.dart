import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:oauth2/oauth2.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/services/auth_service.dart';
import 'package:scalesoft_app/storage/storage.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final AccountRepository _accountService;
  final AccountDbProvider _accountDbProvider;
  final Session _session;
  AuthorizationCodeGrant? _grant;

  AuthBloc(this._authService, this._accountService, this._session, this._accountDbProvider)
      : super(const AuthState.unauthenticated()) {
    on<Authenticate>(_onAuthenticate);
    on<HandleAuthResponse>(_onHandleAuthResponse);
    on<VerifyUser>(_verifyUser);
    on<LogoutUser>(_removeUser);
    on<CancelAuth>(_cancelAuth);
  }

  Future<void> _onAuthenticate(
    Authenticate event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.authenticating());

    try {
      _grant = _authService.getAuthGrant(
        Uri.parse(Constants.issuer),
        Constants.clientId,
        Constants.clientSecret,
        Constants.authorizationEndpoint,
        Constants.tokenEndpoint,
        Constants.endSessionEndpoint,
      );

      emit(
        AuthState.openAuthReqest(
          authUri: _grant!.getAuthorizationUrl(
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
      final tokenResponse = await _grant!.handleAuthorizationResponse(
        event.authRespUri.queryParameters,
      );

      _session.token = AuthToken(
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

      final userAccount = UserAccount(
        user: userInfo.currentUser,
        authToken: _session.token,
        hospital: const Hospital(id: 1, title: 'Na Homolce', iconPath: 'assets/icons/icon_hospital_nahomolce.svg'),
        signedIn: DateTime.now(),
      );

      await _accountDbProvider.save(userAccount);
      _session.userAccount = userAccount;
      emit(AuthState.userVerified(userAccount: userAccount));
    } on Exception catch (e) {
      _session.token = null;
      emit(AuthState.unauthenticated(error: e));
    }
  }

  Future<void> _removeUser(
    LogoutUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _accountDbProvider.remove(_session.userAccount!);
      _session.removeTokens(_session.userAccount!.user.muid);
      _session.token = null;
      _session.userAccount = null;

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
