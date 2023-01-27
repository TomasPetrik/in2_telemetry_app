import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:oauth2/oauth2.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/bloc/user_content/content_bloc.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/parsers/jwt_parser.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/auth_service.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

@singleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final AccountRepository _accountRepository;
  final CarePlansRepository _carePlansRepository;
  final AccountDbProvider _accountDbProvider;
  final Session _session;
  AuthorizationCodeGrant? _grant;
  final Dio _dio;

  AuthBloc(
    this._authService,
    this._accountRepository,
    this._carePlansRepository,
    this._session,
    this._accountDbProvider,
    @Named(Constants.privateDioName) this._dio,
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
    } on Exception {
      emit(const AuthState.unauthenticated());
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
      final userInfo = await _accountRepository.loadUserInfo();

      final userAccount = UserAccount(
        user: userInfo.currentUser,
        authToken: _session.token,
        userPermissions: _session.userPermissions,
        hospital: _session.hospital,
        signedIn: DateTime.now(),
        lastActiveIn: DateTime.now(),
        hasParent: false,
        representedPeople: userInfo.representedPeople
            ?.map(
              (representedPerson) => UserAccount(
                user: representedPerson,
                authToken: _session.token,
                hospital: _session.hospital,
                userPermissions: _session.userPermissions,
                signedIn: DateTime.now(),
                lastActiveIn: null,
                representedPeople: null,
                hasParent: true,
              ),
            )
            .toList(),
      );

      //load and assign care plans, fulfillment_evaluation
      final activeCarePlans = await _carePlansRepository.loadActiveCarePlans(
        patientMuid: userInfo.currentUser.muid,
      );

      for (final carePlan in activeCarePlans.items) {
        final fulfillmentEvaluation =
            await _carePlansRepository.loadFulFillmentEvaluation(
          carePlanVersionId: carePlan.id,
        );
        carePlan.fulfillmentEvaluation = fulfillmentEvaluation;
      }

      userAccount.carePlans = activeCarePlans.items;
      if (userAccount.representedPeople?.isNotEmpty == true) {
        for (final UserAccount representedPerson
            in userAccount.representedPeople!) {
          final activeCarePlans =
              await _carePlansRepository.loadActiveCarePlans(
            patientMuid: representedPerson.user.muid,
          );

          for (final carePlan in activeCarePlans.items) {
            final fulfillmentEvaluation =
                await _carePlansRepository.loadFulFillmentEvaluation(
              carePlanVersionId: carePlan.id,
            );
            carePlan.fulfillmentEvaluation = fulfillmentEvaluation;
          }

          representedPerson.carePlans = activeCarePlans.items;
        }
      }

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

      if (event.userAccount.user.muid == _session.userAccount?.user.muid) {
        _session.removeTokens(_session.userAccount!.user.muid);
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
}
