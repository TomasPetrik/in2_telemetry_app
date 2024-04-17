import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:oauth2/oauth2.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/config.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/data/providers/user_db_provider.dart';
import 'package:scalesoft_app/parsers/jwt_parser.dart';
import 'package:scalesoft_app/data/providers/settings_db_provider.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/repositories/time_settings_repository.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/auth_service.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/utils/events_constants.dart';
import 'package:scalesoft_app/utils/helpers/notifications_helper.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final ReportService _reportsService;
  final AccountRepository _accountRepository;
  final UserDbProvider _userDbProvider;
  final SettingsDbProvider _settingsDbProvider;
  final TimeSettingsRepository _timeSettingsRepository;
  final SyncService _syncService;
  final UserCubit _session;
  AuthorizationCodeGrant? _grant;
  Client? _authClient;
  final Dio _dio;

  AuthBloc(
    this._authService,
    this._reportsService,
    this._accountRepository,
    this._session,
    this._userDbProvider,
    @Named(ConfigurationConstants.privateDioName) this._dio,
    this._syncService,
    this._settingsDbProvider,
    this._timeSettingsRepository,
  ) : super(const AuthState.unauthenticated()) {
    on<AuthFromColdStart>(_onAuthFromColdStart);
    on<Authenticate>(_onAuthenticate);
    on<LogoutUser>(_removeUser);
    on<CancelAuth>(_cancelAuth);
    on<ErrorLoadDataEvent>(_onErrorLoadDataEvent);
  }

  Future<void> _onAuthFromColdStart(
    AuthFromColdStart event,
    Emitter<AuthState> emit,
  ) async {
    final settings = await _settingsDbProvider.getSettings();

    final hospital = Config.value.hospitals.firstWhereOrNull((x) => x.id == settings.lastHospitalId);
    if (hospital == null) {
      return;
    }

    _grant = _authService.getAuthGrant(
      Config.value.clientId,
      Config.value.clientSecret,
      hospital.authData.authUrl,
      hospital.authData.tokenUrl,
      settings.currentCodeVerifier,
    );

    _grant!.getAuthorizationUrl(
      Uri.parse(Config.value.redirectUrl),
      scopes: Config.value.scopes,
    );

    _authClient = await _grant!.handleAuthorizationResponse(
      event.authUri.queryParameters,
    );

    if (_authClient != null) {
      _reportsService.trackEvent(
        severity: LogSeverity.info,
        message: EventsConstants.eventUserAuthByColdStart,
      );
      await _handleAuthResponse(emit, hospital);
    }
  }

  Future<void> _onAuthenticate(
    Authenticate event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthState.authenticating());

      final codeVerifier = _authService.createCodeVerifier();

      _grant = _authService.getAuthGrant(
        Config.value.clientId,
        Config.value.clientSecret,
        event.hospital.authData.authUrl,
        event.hospital.authData.tokenUrl,
        codeVerifier,
      );

      _settingsDbProvider.updateAppSettings(
        AppSettingsCompanion(lastHospitalId: Value(event.hospital.id), currentCodeVerifier: Value(codeVerifier)),
      );

      _reportsService.trackEvent(
        severity: LogSeverity.info,
        message: EventsConstants.eventUserOpenAuthReqInBrowser,
      );

      _authClient = await _authService.authorize(
        _grant!,
        Config.value.scopes,
        Config.value.redirectUrl,
      );

      if (_authClient != null) {
        await _handleAuthResponse(emit, event.hospital);
      }
    } on Exception {
      _reportsService.trackEvent(
        severity: LogSeverity.error,
        message: EventsConstants.eventUserUnauthenticated,
      );
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _handleAuthResponse(
    Emitter<AuthState> emit,
    Hospital hospital,
  ) async {
    try {
      _reportsService.trackEvent(
        severity: LogSeverity.info,
        message: EventsConstants.eventUserAuthenticating,
      );

      _dio.options = _dio.options.copyWith(baseUrl: hospital.authData.baseUrl);

      final userPermissions = JwtParser(jwtToken: _authClient!.credentials.accessToken).getUserPermissions();

      final token = AuthToken(
        _authClient!.credentials.accessToken,
        _authClient!.credentials.refreshToken!,
        _authClient!.credentials.expiration!,
      );

      _reportsService.trackEvent(
        severity: LogSeverity.info,
        message: EventsConstants.eventUserAuthenticated,
      );
      emit(AuthState.authenticated(credentials: _authClient!.credentials));
      await _verifyUser(emit, token, userPermissions, hospital);
    } on Exception {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _verifyUser(
    Emitter<AuthState> emit,
    AuthToken token,
    List<String> permissions,
    Hospital hospital,
  ) async {
    try {
      _reportsService.trackEvent(
        severity: LogSeverity.info,
        message: EventsConstants.eventUserLoadingInfo,
      );
      final userInfo = await _accountRepository.loadUserInfo(
        authToken: token,
        apiUrl: hospital.authData.baseUrl,
      );

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
      final timeSettings = await _timeSettingsRepository.loadTimeSettings(token, hospital.authData.baseUrl);

      final userId = await _session.createOrUpdateUser(
        userInfo.currentUser,
        userInfo.representedPeople,
        hospital.id,
        token,
        permissions,
        timeSettings,
      );

      await _session.setActiveUser(userId);

      _reportsService.trackEvent(
        userId: userId,
        severity: LogSeverity.info,
        message: EventsConstants.eventUserLoaded,
      );

      await _syncService.loadDeviceModels(userId);
      await _syncService.loadWhenValues(userId);

      await _syncService.loadUserData(userId);
      //syncResults() in case if user has some offline results not synced due session expiration
      await _syncService.syncResults();
      // await _accountDbProvider.save(user);

      emit(AuthState.userVerified(userAccount: _session.state.currentUser));
    } catch (e) {
      _reportsService.trackEvent(
        severity: LogSeverity.error,
        message: EventsConstants.eventUserUnauthenticated,
      );
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _removeUser(
    LogoutUser event,
    Emitter<AuthState> emit,
  ) async {
    try {
      NotificationsHelper.removeUserNotifications(
        notificationsPlugin: FlutterLocalNotificationsPlugin(),
        userAccount: event.userAccount,
      );
      await _userDbProvider.remove(event.userAccount.id);

      // If we've removed the last account
      if (_session.state.rootUsers.where((x) => x.id != event.userAccount.id).isEmpty) {
        getIt<ContentBloc>().add(const SwitchNoUserContentEvent());
      }
    } on Exception catch (e) {
      emit(AuthState.logoutFailed(error: e));
    }
  }

  Future<void> _cancelAuth(
    CancelAuth event,
    Emitter<AuthState> emit,
  ) async {
    _reportsService.trackEvent(
      severity: LogSeverity.warning,
      message: EventsConstants.eventUserAuthCancelled,
    );
    emit(const AuthState.cancelled());
  }

  Future<void> _onErrorLoadDataEvent(
    ErrorLoadDataEvent event,
    Emitter<AuthState> emit,
  ) async {
    _reportsService.trackEvent(
      severity: LogSeverity.error,
      message: EventsConstants.eventUserErrorDataLoaded,
    );
    emit(const AuthState.errorLoadData());
  }
}
