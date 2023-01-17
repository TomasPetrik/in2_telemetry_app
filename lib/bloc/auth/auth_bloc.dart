import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:oauth2/oauth2.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/auth_service.dart';
import 'package:scalesoft_app/storage/storage.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final AccountRepository _accountService;
  final AccountDbProvider _accountDbProvider;
  final Session _session;
  AuthorizationCodeGrant? _grant;

  AuthBloc(
    this._authService,
    this._accountService,
    this._session,
    this._accountDbProvider,
  ) : super(const AuthState.unauthenticated()) {
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
        Constants.clientId,
        Constants.clientSecret,
        event.hospital.authData.authUrl,
        event.hospital.authData.tokenUrl,
      );

      _session.hospital = event.hospital;

      emit(
        AuthState.openAuthRequest(
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
        hospital: _session.hospital,
        signedIn: DateTime.now(),
        lastActiveIn: DateTime.now(),
        representedPeople: userInfo.representedPeople
            ?.map(
              (representedPerson) => UserAccount(
                user: representedPerson,
                authToken: _session.token,
                hospital: _session.hospital,
                signedIn: DateTime.now(),
                lastActiveIn: null,
                representedPeople: null,
              ),
            )
            .toList(),
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
      await _accountDbProvider.remove(event.userAccount);

      if (event.userAccount.user.muid == _session.userAccount?.user.muid) {
        _session.removeTokens(_session.userAccount!.user.muid);
        _session.token = null;
        _session.userAccount = null;

        final lastLoggedUser = _accountDbProvider.getLast();
        if (lastLoggedUser != null) {
          getIt<ContentBloc>().add(
            SwitchUserContentEvent(
              userAccount: lastLoggedUser,
            ),
          );
        } else {
          getIt<ContentBloc>().add(const SwitchNoUserContentEvent());
        }
        emit(const AuthState.logoutSuccess());
      } else {
        emit(AuthState.inactiveUserRemoved(userAccount: event.userAccount));
      }
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

  Future<void> _restoreLastAccount(
    Emitter<AuthState> emit,
  ) async {
    final lastAccount = _accountDbProvider.getLast();
    if (lastAccount != null) {
      _session.userAccount = lastAccount;
      _session.token = lastAccount.authToken;
      _session.hospital = lastAccount.hospital;
    }

    emit(AuthState.lastSessionRestored(userAccount: lastAccount));
  }
}
