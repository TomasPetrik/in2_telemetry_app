import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final AccountDbProvider _accountDbProvider;
  final Session _session;

  ContentBloc(this._accountDbProvider, this._session)
      : super(const ContentState.initial()) {
    on<CheckLastLoggedUserContentEvent>(_checkLastLoggedUserContentEvent);
    on<OnUserAddedContentEvent>(_onUserAddedContentEvent);
    on<SwitchUserContentEvent>(_switchUserContentEvent);
    on<SwitchMultiUserContentEvent>(_switchMultiUserContentEvent);
    on<SwitchNoUserContentEvent>(_switchNoUserContentEvent);
    on<OnAppearanceChangedContentEvent>(_onAppearanceChangedContentEvent);
  }

  Future<void> _checkLastLoggedUserContentEvent(
    CheckLastLoggedUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    //TODO.. _session.isMultiUser should be kept in memory 
    //and any switch content should re-write this _session.isMultiUser value

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
    _session.isMultiUser = false;
    late UserAccount parentAccount;

    if (event.userAccount.parentId?.isNotEmpty == true) {
      parentAccount = _accountDbProvider.get(event.userAccount.parentId!)!;
      final childAccount = parentAccount.representedPeople?.firstWhere(
        (userAccount) => userAccount.user.muid == event.userAccount.user.muid,
      );
      childAccount?.lastActiveIn = DateTime.now();
      _session.userAccount = childAccount;
      _session.token = event.userAccount.authToken;
    } else {
      _session.userAccount =
          event.userAccount.copyWith(lastActiveIn: DateTime.now());
      _session.token = event.userAccount.authToken;
      parentAccount = _session.userAccount!;
    }

    _accountDbProvider.save(parentAccount);

    //todo.. try to re-load care plans automatically,
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

  Future<void> _switchMultiUserContentEvent(
    SwitchMultiUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _session.isMultiUser = true;
    emit(const ContentState.activeAllUsers());
  }

  Future<void> _switchNoUserContentEvent(
    SwitchNoUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _session.isMultiUser = false;
    emit(const ContentState.unauthenticated());
  }

  Future<void> _onAppearanceChangedContentEvent(
    OnAppearanceChangedContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(const ContentState.onAppearanceChanged());
  }
}
