import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/user_content/user_content_event.dart';
import 'package:scalesoft_app/bloc/user_content/user_content_state.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/storage/storage.dart';

@singleton
class UserContentBloc extends Bloc<UserContentEvent, UserContentState> {
  final AccountDbProvider _accountDbProvider;
  final Session _session;

  UserContentBloc(this._accountDbProvider, this._session) : super(const UserContentState.initial()) {
    on<CheckLastLoggedUserContentEvent>(_checkLastLoggedUserContentEvent);
    on<SwitchUserContentEvent>(_switchUserContentEvent);
    on<SwitchAllUsersContentEvent>(_switchAllUsersContentEvent);
    on<SwitchNoUserContentEvent>(_switchNoUserContentEvent);
  }

  Future<void> _checkLastLoggedUserContentEvent(
    CheckLastLoggedUserContentEvent event,
    Emitter<UserContentState> emit,
  ) async {
    final userAccount = _accountDbProvider.getLast();
    emit(
      userAccount == null ? const UserContentState.noUser() : UserContentState.activeSingleUser(userAccount),
    );
  }

  Future<void> _switchUserContentEvent(
    SwitchUserContentEvent event,
    Emitter<UserContentState> emit,
  ) async {
    _session.userAccount = event.userAccount;
    _session.token = event.userAccount.authToken;
    emit(UserContentState.activeSingleUser(event.userAccount));
  }

  Future<void> _switchAllUsersContentEvent(
    SwitchAllUsersContentEvent event,
    Emitter<UserContentState> emit,
  ) async {
    emit(const UserContentState.activeAllUsers());
  }

  Future<void> _switchNoUserContentEvent(
    SwitchNoUserContentEvent event,
    Emitter<UserContentState> emit,
  ) async {
    emit(const UserContentState.noUser());
  }
}
