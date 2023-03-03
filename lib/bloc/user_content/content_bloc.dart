import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/session_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/storage/session.dart';

@singleton
class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final AccountDbProvider _accountDbProvider;
  final SessionDbProvider _sessionDbProvider;
  final Session _session;

  ContentBloc(this._accountDbProvider, this._sessionDbProvider, this._session)
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
    initBackgroundFetch();

    final userAccount = _accountDbProvider.getLast();
    final isMultiUser = _sessionDbProvider.isMultiUser();
    if (userAccount == null) {
      emit(const ContentState.unauthenticated());

      BackgroundFetch.stop().then((int status) {
        debugPrint('[BackgroundFetch] stop success: $status');
      });
    } else {
      _session.userAccount = userAccount;
      _session.token = userAccount.authToken;
      _session.isMultiUser = isMultiUser;

      //Do all sync always when start app
      getIt<SyncBloc>().add(const SyncEvent.syncAll());

      //If is logged-in atleast one user , then try periodically fetching data for update
      BackgroundFetch.start().then((int status) {
        debugPrint('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        debugPrint('[BackgroundFetch] start FAILURE: $e');
      });

      emit(const ContentState.activeMode());
    }
  }

  Future<void> _switchUserContentEvent(
    SwitchUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _session.isMultiUser = false;
    _sessionDbProvider.setIsMultiUser(false);

    final UserAccount parentAccount;

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

    //Try to re-load care plans when switch user
    getIt<SyncBloc>().add(const SyncEvent.syncAll());

    emit(const ContentState.activeMode());
  }

  Future<void> _switchMultiUserContentEvent(
    SwitchMultiUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _session.isMultiUser = true;
    _sessionDbProvider.setIsMultiUser(true);
    emit(const ContentState.activeMode());
  }

  Future<void> _onUserAddedContentEvent(
    OnUserAddedContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _session.userAccount = event.userAccount;
    _session.userAccount =
        event.userAccount.copyWith(lastActiveIn: DateTime.now());
    _session.token = event.userAccount.authToken;
    _session.isMultiUser = false;
    _sessionDbProvider.setIsMultiUser(false);

    //Same as during check last logged-in user
    //Make sure that if any user is active, we should start periodic background fetch
    BackgroundFetch.start().then((int status) {
      debugPrint('[BackgroundFetch] start success: $status');
    }).catchError((e) {
      debugPrint('[BackgroundFetch] start FAILURE: $e');
    });

    emit(ContentState.onUserAdded(event.userAccount));
  }

  Future<void> _switchNoUserContentEvent(
    SwitchNoUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    BackgroundFetch.stop().then((int status) {
      debugPrint('[BackgroundFetch] stop success: $status');
    });

    _session.isMultiUser = false;
    _sessionDbProvider.setIsMultiUser(false);
    emit(const ContentState.unauthenticated());
  }

  Future<void> _onAppearanceChangedContentEvent(
    OnAppearanceChangedContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentState.onAppearanceChanged(event.themeMode));
  }
}

Future<void> initBackgroundFetch() async {
  int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ), (String taskId) async {
    debugPrint("[BackgroundFetch] Event received $taskId");
    await getIt<SyncService>().syncAllData();

    //Here must be signal completion of this task or the OS can punish app for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }, (String taskId) async {
    //If this task has exceeded its allowed running-time. It must be stopped immediately finish(taskId)
    debugPrint("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
    BackgroundFetch.finish(taskId);
  });
  debugPrint('[BackgroundFetch] configure success: $status');
}
