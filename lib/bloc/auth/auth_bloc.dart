import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:oauth2/oauth2.dart';
import 'package:scalesoft_app/api/model/auth_token.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/config.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/parsers/jwt_parser.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/auth_service.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/constants.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final AccountRepository _accountRepository;
  final AccountDbProvider _accountDbProvider;
  final PendingResultsDbProvider _pendingResultsDbProvider;
  final SyncService _syncService;
  final Session _session;
  AuthorizationCodeGrant? _grant;
  final Dio _dio;

  AuthBloc(
    this._authService,
    this._accountRepository,
    this._session,
    this._accountDbProvider,
    this._pendingResultsDbProvider,
    @Named(Constants.privateDioName) this._dio,
    this._syncService,
  ) : super(const AuthState.unauthenticated()) {
    on<Authenticate>(_onAuthenticate);
    on<HandleAuthResponse>(_onHandleAuthResponse);
    on<VerifyUser>(_verifyUser);
    on<LogoutUser>(_removeUser);
    on<CancelAuth>(_cancelAuth);
    on<ErrorLoadDataEvent>(_onErrorLoadDataEvent);
  }

  Future<void> _onAuthenticate(
    Authenticate event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.authenticating());

    try {
      _grant = _authService.getAuthGrant(
        Config.value.clientId,
        Config.value.clientSecret,
        event.hospital.authData.authUrl,
        event.hospital.authData.tokenUrl,
      );

      _session.hospital = event.hospital;

      emit(
        AuthState.openAuthRequest(
          authUri: _grant!.getAuthorizationUrl(
            Uri.parse(Config.value.redirectUrl),
            scopes: Config.value.scopes,
            state: DateTime.now().toString(),
          ),
        ),
      );
    } on Exception {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onHandleAuthResponse(
    HandleAuthResponse event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthState.handlingResponse());

      final tokenResponse = await _grant!.handleAuthorizationResponse(
        event.authRespUri.queryParameters,
      );

      _dio.options =
          _dio.options.copyWith(baseUrl: _session.hospital!.authData.baseUrl);

      _session.userPermissions =
          JwtParser(jwtToken: tokenResponse.credentials.accessToken)
              .getUserPermissions();

      _session.token = AuthToken(
        tokenResponse.credentials.accessToken,
        tokenResponse.credentials.refreshToken!,
        tokenResponse.credentials.expiration!,
      );

      emit(AuthState.authenticated(credentials: tokenResponse.credentials));
    } on Exception {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _verifyUser(
    VerifyUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final userInfo =
          await _accountRepository.loadUserInfo(authToken: _session.token!);

      final userAccount = UserAccount(
        user: userInfo.currentUser,
        assignedDevices: userInfo.assignedDevices,
        authToken: _session.token,
        userPermissions: _session.userPermissions,
        hospital: _session.hospital,
        signedIn: DateTime.now(),
        lastActiveIn: DateTime.now(),
        parentId: null,
        sessionExpired: false,
        lastSyncAt: DateTime.now(),
        lastSyncFailed: false,
        representedPeople: userInfo.representedPeople
            ?.map(
              (representedPerson) => UserAccount(
                user: representedPerson,
                assignedDevices: userInfo.assignedDevices,
                authToken: _session.token,
                hospital: _session.hospital,
                userPermissions: _session.userPermissions,
                signedIn: DateTime.now(),
                lastActiveIn: null,
                representedPeople: null,
                parentId: userInfo.currentUser.muid,
                sessionExpired: false,
                lastSyncAt: DateTime.now(),
                lastSyncFailed: false,
              ),
            )
            .toList(),
      );

      await _syncService.loadDeviceModels(userAccount);
      await _syncService.loadWhenValues(userAccount);
      await _syncService.loadTimeSettings(userAccount);
      await _syncService.loadUserData(userAccount);
      //syncResults() in case if user has some offline results not synced due session expiration
      await _syncService.syncResults();
      await _accountDbProvider.save(userAccount);
      _session.userAccount = userAccount;
      emit(AuthState.userVerified(userAccount: userAccount));
    } on Exception {
      _session.token = null;
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _removeUser(
    LogoutUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _accountDbProvider.remove(event.userAccount);
      await _pendingResultsDbProvider
          .removeUserResults(event.userAccount.user.muid);

      if (event.userAccount.user.muid == _session.userAccount?.user.muid) {
        _session.token = null;
        _session.userAccount = null;
        _session.hospital = null;
        _session.userPermissions = null;

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

  Future<void> _onErrorLoadDataEvent(
    ErrorLoadDataEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.errorLoadData());
  }
}
