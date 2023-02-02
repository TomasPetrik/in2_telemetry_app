import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_state.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final AccountDbProvider _accountDbProvider;
  final CarePlansRepository _carePlansRepository;
  final Session _session;

  ContentBloc(this._accountDbProvider, this._session, this._carePlansRepository)
      : super(const ContentState.initial()) {
    on<CheckLastLoggedUserContentEvent>(_checkLastLoggedUserContentEvent);
    on<OnUserAddedContentEvent>(_onUserAddedContentEvent);
    on<SwitchUserContentEvent>(_switchUserContentEvent);
    on<SwitchAllUsersContentEvent>(_switchAllUsersContentEvent);
    on<SwitchNoUserContentEvent>(_switchNoUserContentEvent);
    on<OnAppearanceChangedContentEvent>(_onAppearanceChangedContentEvent);
  }

  Future<void> _checkLastLoggedUserContentEvent(
    CheckLastLoggedUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    final userAccount = _accountDbProvider.getLast();
    if (userAccount == null) {
      emit(const ContentState.unauthenticated());
    } else {
      _session.userAccount = userAccount;
      _session.token = userAccount.authToken;

      //todo.. try to load care plans,
      //if is in offline mode, then just switch user

      emit(ContentState.activeSingleUser(userAccount));
    }
  }

  Future<void> _switchUserContentEvent(
    SwitchUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _session.userAccount =
        event.userAccount.copyWith(lastActiveIn: DateTime.now());
    _session.token = event.userAccount.authToken;

    _accountDbProvider.save(_session.userAccount!);

    //todo.. try to load care plans,
    //if is in offline mode, then just switch user
    /*
    final activePlans = await _carePlansRepository.loadActiveCarePlans(
      patientMuid: event.userAccount.user.muid,
    );
    _accountDbProvider.save(event.userAccount.copyWith(carePlans: activePlans.items));
    //todo.. save this plans for user
    */

    emit(ContentState.activeSingleUser(event.userAccount));
  }

  Future<void> _onUserAddedContentEvent(
    OnUserAddedContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _session.userAccount = event.userAccount;
    _session.token = event.userAccount.authToken;
    emit(ContentState.onUserAdded(event.userAccount));
  }

  Future<void> _switchAllUsersContentEvent(
    SwitchAllUsersContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(const ContentState.activeAllUsers());
  }

  Future<void> _switchNoUserContentEvent(
    SwitchNoUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(const ContentState.unauthenticated());
  }

  Future<void> _onAppearanceChangedContentEvent(
    OnAppearanceChangedContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(const ContentState.onAppearanceChanged());
  }
}
