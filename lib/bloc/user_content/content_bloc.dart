import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/report/report.dart';
import 'package:scalesoft_app/app.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_event.dart';
import 'package:scalesoft_app/bloc/user_content/content_state.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/session_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/events_constants.dart';
import 'package:uni_links/uni_links.dart';

@singleton
class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final AccountDbProvider _accountDbProvider;
  final SessionDbProvider _sessionDbProvider;
  final Session _session;
  final CarePlanBloc _carePlanBloc;
  final ReportService _reportsService;
  bool _initialUriIsHandled = false;
  Timer? _watchDogTimer;

  ContentBloc(
    this._accountDbProvider,
    this._sessionDbProvider,
    this._session,
    this._carePlanBloc,
    this._reportsService,
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

  void _autoRefreshDashboard() {
    _reportsService.trackEvent(
      userAccount: _session.isMultiUser == false ? _session.userAccount : null,
      severity: Severity.info,
      message: EventsConstants.eventAutoRefreshDashboard,
    );
    //1. Notify dashboard to refresh screen
    _carePlanBloc.add(const RefreshStateEvent());
  }

  Future<void> _startWatchDog() async {
    //start of exact minute
    final offsetSec = 60 - DateTime.now().second + 1;
    await Future.delayed(Duration(seconds: offsetSec));
    _autoRefreshDashboard();

    _watchDogTimer?.cancel();
    _watchDogTimer = Timer.periodic(const Duration(seconds: 60), (Timer timer) {
      getIt<ReportService>().trackEvent(severity: Severity.info, message: "Refresh dashboard");
      _autoRefreshDashboard();
    });
  }

  Future<Uri?> _getInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await getInitialUri();
        return uri;
      } on PlatformException {
        return null;
      } on FormatException catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _checkLastLoggedUserContentEvent(
    CheckLastLoggedUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    await _reportsService.removeOldLogs();

    final initialUri = await _getInitialUri();
    if (initialUri != null) {
      emit(ContentState.tryCompleteAuth(initialUri));
      return;
    }

    final userAccount = _accountDbProvider.getLast();
    final isMultiUser = _sessionDbProvider.isMultiUser();
    if (userAccount == null) {
      _reportsService.trackEvent(
        userAccount: isMultiUser == false ? _session.userAccount : null,
        severity: Severity.info,
        message: EventsConstants.eventNoLastUserDetected,
      );
      emit(const ContentState.unauthenticated());

      _stopBackgroundFetch();
    } else {
      _session.userAccount = userAccount;
      _session.isMultiUser = isMultiUser;

      _reportsService.trackEvent(
        userAccount: userAccount,
        severity: Severity.info,
        message: EventsConstants.eventUserContentDefaultAutoSet,
      );

      //Do all sync always when start app but not from cold start
      if (initialUri == null) {
        getIt<SyncBloc>().add(const SyncEvent.syncAll());
      }

      //If is logged-in atleast one user , then try periodically fetching data for update
      _startBackgroundFetch();
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
      _session.userAccount = event.userAccount.copyWith(lastActiveIn: DateTime.now());
      parentAccount = _session.userAccount!;
    }

    _accountDbProvider.save(parentAccount);

    _reportsService.trackEvent(
      userAccount: parentAccount,
      severity: Severity.info,
      message: EventsConstants.eventUserSwitchedToActive,
    );

    //Try to re-load care plans when switch user
    getIt<SyncBloc>().add(const SyncEvent.syncAll());

    emit(ContentState.activeMode(UniqueKey()));
  }

  Future<void> _switchMultiUserContentEvent(
    SwitchMultiUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _reportsService.trackEvent(
      userAccount: _session.isMultiUser == false ? _session.userAccount : null,
      severity: Severity.info,
      message: EventsConstants.eventSwitchToMultiuser,
    );
    _session.isMultiUser = true;
    _sessionDbProvider.setIsMultiUser(true);
    emit(ContentState.activeMode(UniqueKey()));
  }

  Future<void> _onUserAddedContentEvent(
    OnUserAddedContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _session.userAccount = event.userAccount.copyWith(lastActiveIn: DateTime.now());
    _session.isMultiUser = false;
    _sessionDbProvider.setIsMultiUser(false);

    //Same as during check last logged-in user
    //Make sure that if any user is active, we should start periodic background fetch
    _startBackgroundFetch();

    _reportsService.trackEvent(
      userAccount: event.userAccount,
      severity: Severity.info,
      message: EventsConstants.eventUserAdded,
    );

    emit(ContentState.onUserAdded(event.userAccount));
  }

  Future<void> _switchNoUserContentEvent(
    SwitchNoUserContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _stopBackgroundFetch();

    _reportsService.trackEvent(
      userAccount: _session.isMultiUser == false ? _session.userAccount : null,
      severity: Severity.info,
      message: EventsConstants.eventNoUserContent,
    );
    _session.isMultiUser = false;
    _sessionDbProvider.setIsMultiUser(false);
    emit(const ContentState.unauthenticated());
  }

  Future<void> _onAppearanceChangedContentEvent(
    OnAppearanceChangedContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _reportsService.trackEvent(
      userAccount: _session.isMultiUser == false ? _session.userAccount : null,
      severity: Severity.info,
      message: EventsConstants.eventAppearanceChanged,
    );
    emit(ContentState.onAppearanceChanged(event.themeMode));
  }

  Future<void> _onDaylightAppearanceChangedContentEvent(
    OnDaylightAppearanceChangedContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    _reportsService.trackEvent(
      userAccount: _session.isMultiUser == false ? _session.userAccount : null,
      severity: Severity.info,
      message: EventsConstants.eventDaylightAppearanceChanged,
    );
    emit(ContentState.onDaylightAppearanceChanged(event.originalLocation));
  }

  Future<void> _onStopWatchDog(
    StopWatchDog event,
    Emitter<ContentState> emit,
  ) async {
    _watchDogTimer?.cancel();
  }
}

void _stopBackgroundFetch() {
  BackgroundFetch.stop().then((int status) {
    getIt<ReportService>().trackEvent(severity: Severity.info, message: 'BS - stop status: $status');
  }).catchError((e) {
    getIt<ReportService>().trackEvent(severity: Severity.info, message: 'BS - stop failure: $e');
  });
}

//onFetch
void _onBackgroundFetch(String taskId) async {
  getIt<ReportService>().trackEvent(severity: Severity.info, message: "BS - _onBackgroundFetch(), id: $taskId");

  await getIt<SyncService>().syncAllData(syncAllUsers: true);

  //Here must be signal completion of this task or the OS can punish app for taking too long in the background.
  BackgroundFetch.finish(taskId);
}

/// This event fires shortly before your task is about to timeout.  You must finish any outstanding work and call BackgroundFetch.finish(taskId).
Future<void> _onBackgroundFetchTimeout(String taskId) async {
  //If this task has exceeded its allowed running-time. It must be stopped immediately finish(taskId)
  getIt<ReportService>().trackEvent(severity: Severity.info, message: 'BS - _onBackgroundFetchTimeout(), id: $taskId');

  BackgroundFetch.finish(taskId);
}

Future<void> _startBackgroundFetch() async {
  getIt<ReportService>().trackEvent(severity: Severity.info, message: 'BS - init background fetch');

  int status = await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: ConfigurationConstants.autoSyncIntervalMinutes,
      forceAlarmManager: false,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.NONE,
    ),
    _onBackgroundFetch,
    _onBackgroundFetchTimeout,
  );

  getIt<ReportService>().trackEvent(severity: Severity.info, message: 'BS - configure status: $status');

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}

  getIt<ReportService>().trackEvent(severity: Severity.info, message: 'BS - registering headless task');

  bool registered = await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  getIt<ReportService>().trackEvent(severity: Severity.info, message: 'BS - registered headless task: $registered');
  getIt<ReportService>().trackEvent(severity: Severity.info, message: 'BS - schedulling first task in 5 seconds..');

}
