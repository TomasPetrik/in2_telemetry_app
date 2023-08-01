import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/session_db_provider.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/location_service.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:scalesoft_app/utils/extensions/theme_mode_extensions.dart';
import 'package:scalesoft_app/utils/helpers/appearance_helper.dart';

@singleton
class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final AccountDbProvider _accountDbProvider;
  final SessionDbProvider _sessionDbProvider;
  final AppSettingsDbProvider _appSettingsDbProvider;
  final Session _session;
  final CarePlanBloc _carePlanBloc;
  final LocationService _locationService;
  final ReportService _reportService;
  Timer? _watchDogTimer;
  GoRouter? goRouter;

  ContentBloc(
    this._accountDbProvider,
    this._sessionDbProvider,
    this._appSettingsDbProvider,
    this._session,
    this._carePlanBloc,
    this._locationService,
    this._reportService,
  ) : super(const ContentState.initial()) {
    on<CheckLastLoggedUserContentEvent>(_checkLastLoggedUserContentEvent);
    on<OnUserAddedContentEvent>(_onUserAddedContentEvent);
    on<SwitchUserContentEvent>(_switchUserContentEvent);
    on<SwitchMultiUserContentEvent>(_switchMultiUserContentEvent);
    on<SwitchNoUserContentEvent>(_switchNoUserContentEvent);
    on<OnAppearanceChangedContentEvent>(_onAppearanceChangedContentEvent);
    on<OnDaylightAppearanceChangedContentEvent>(
      _onDaylightAppearanceChangedContentEvent,
    );
    on<StopWatchDog>(_onStopWatchDog);
  }

  Future<void> _checkAutoAppearanceMode() async {
    final appSettings = _appSettingsDbProvider.read();
    if (appSettings == null) return;
    if (appSettings.autosetAppearance == true) {
      final newThemeMode = await _locationService.getThemeModeByDayLight();
      if (appSettings.themeModeLocal != newThemeMode.toLocal()) {
        await _appSettingsDbProvider.write(
          appSettings.copyWith(themeModeLocal: newThemeMode.toLocal()),
        );

        AppearanceHelper.setSystemUIOverlayStyle(ThemeMode.light);
        final originalLocation = goRouter!.location;
        add(OnDaylightAppearanceChangedContentEvent(originalLocation));
      }
    }
  }

  void _notifyEssentials() {
    //1. Notify dashboard to refresh screen
    _carePlanBloc.add(const RefreshStateEvent());

    //2. Check auto-appearance if is enabled
    _checkAutoAppearanceMode();
  }

  Future<void> _startWatchDog() async {
    //start of exact minute
    final offsetSec = 60 - DateTime.now().second + 1;
    //debugPrint('watchdog will start after $offsetSec seconds');
    await Future.delayed(Duration(seconds: offsetSec));
    _notifyEssentials();

    //debugPrint('watchdog started on ${DateTime.now().toIso8601String()}}');
    _watchDogTimer?.cancel();
    _watchDogTimer = Timer.periodic(const Duration(seconds: 60), (Timer timer) {
      debugPrint('notifing essentials');
      _notifyEssentials();
    });
  }

  Future<void> _checkLastLoggedUserContentEvent(
    CheckLastLoggedUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    goRouter = event.goRouter;
    initBackgroundFetch();

    await _reportService.removeOldLogs();

    final userAccount = _accountDbProvider.getLast();
    final isMultiUser = _sessionDbProvider.isMultiUser();
    if (userAccount == null) {
      emit(const ContentState.unauthenticated());

      BackgroundFetch.stop().then((int status) {
        debugPrint('[BackgroundFetch] stop success: $status');
      });
    } else {
      _session.userAccount = userAccount;
      _session.isMultiUser = isMultiUser;

      //Do all sync always when start app
      getIt<SyncBloc>().add(const SyncEvent.syncAll());

      //If is logged-in atleast one user , then try periodically fetching data for update
      BackgroundFetch.start().then((int status) {
        debugPrint('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        debugPrint('[BackgroundFetch] start FAILURE: $e');
      });

      emit(ContentState.activeMode(UniqueKey()));
    }

    _startWatchDog();
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
    } else {
      _session.userAccount =
          event.userAccount.copyWith(lastActiveIn: DateTime.now());
      parentAccount = _session.userAccount!;
    }

    _accountDbProvider.save(parentAccount);

    //Try to re-load care plans when switch user
    getIt<SyncBloc>().add(const SyncEvent.syncAll());

    emit(ContentState.activeMode(UniqueKey()));
  }

  Future<void> _switchMultiUserContentEvent(
    SwitchMultiUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _session.isMultiUser = true;
    _sessionDbProvider.setIsMultiUser(true);
    emit(ContentState.activeMode(UniqueKey()));
  }

  Future<void> _onUserAddedContentEvent(
    OnUserAddedContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _session.userAccount = event.userAccount;
    _session.userAccount =
        event.userAccount.copyWith(lastActiveIn: DateTime.now());
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

  Future<void> _onDaylightAppearanceChangedContentEvent(
    OnDaylightAppearanceChangedContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentState.onDaylightAppearanceChanged(event.originalLocation));
  }

  Future<void> _onStopWatchDog(
    StopWatchDog event,
    Emitter<ContentState> emit,
  ) async {
    _watchDogTimer?.cancel();
  }
}

Future<void> initBackgroundFetch() async {
  int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: Constants.autoSyncIntervalMinutes,
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
