import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_state.dart';
import 'package:scalesoft_app/globals.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/settings_db_provider.dart';
import 'package:scalesoft_app/utils/extensions/locale_extensions.dart';
import 'package:scalesoft_app/utils/extensions/theme_mode_extensions.dart';
import 'package:scalesoft_app/utils/helpers/notifications_helper.dart';

@singleton
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final AccountDbProvider _accountDbProvider;
  final AppSettingsDbProvider _appSettingsDbProvider;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<bool> notificationsStreamController =
      StreamController<bool>.broadcast();

  bool requestedForPermission = false;

  NotificationsBloc(
    this._accountDbProvider,
    this._appSettingsDbProvider,
  ) : super(const NotificationsState.init()) {
    on<NotificationsEvent>(
      (event, emit) async {
        await event.when(
          initPlugin: () async {
            const AndroidInitializationSettings initializationSettingsAndroid =
                AndroidInitializationSettings('ic_launcher_foreground');
            final DarwinInitializationSettings initializationSettingsDarwin =
                DarwinInitializationSettings(
              onDidReceiveLocalNotification: onDidReceiveLocalNotification,
            );
            final InitializationSettings initializationSettings =
                InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsDarwin,
            );
            await _notificationsPlugin.initialize(
              initializationSettings,
              onDidReceiveNotificationResponse:
                  onDidReceiveNotificationResponse,
              onDidReceiveBackgroundNotificationResponse:
                  notificationTapBackground,
            );

            final appSettings = _getAppSettings();

            NotificationsHelper.setNotifications(
              appSettings: appSettings,
              notificationsPlugin: _notificationsPlugin,
              userAccounts: _accountDbProvider.getAll(),
            );
          },
          initSettings: () async {
            AppSettings appSettings = _getAppSettings();
            //get most recent permission status of notification
            bool isGranted = await Permission.notification.isGranted;

            AppSettings newAppSettings =
                appSettings.copyWith(enabledNotifications: isGranted);

            await _appSettingsDbProvider.write(newAppSettings);

            emit(
              NotificationsState.loaded(
                timestamp: DateTime.now().microsecondsSinceEpoch,
                appSettings: newAppSettings,
                allowedInSystem: isGranted,
              ),
            );
          },
          setNotificationsBySystemSettings: () async {
            bool isGranted = await Permission.notification.isGranted;
            AppSettings appSettings = _getAppSettings();
            AppSettings newAppSettings =
                appSettings.copyWith(enabledNotifications: isGranted);

            await _appSettingsDbProvider.write(newAppSettings);

            if (requestedForPermission == false) {
              requestedForPermission = true;
              add(
                const NotificationsEvent.requestNotificationPermissionIfNeed(),
              );
            }
          },
          requestNotificationPermissionIfNeed: () async {
            await Permission.notification.request().then((status) {
              if (status != PermissionStatus.granted) {
                emit(const NotificationsState.denied());
              }
            });
          },
          setNotifications: () {
            final appSettings = _appSettingsDbProvider.read();

            NotificationsHelper.setNotifications(
              appSettings: appSettings,
              notificationsPlugin: _notificationsPlugin,
              userAccounts: _accountDbProvider.getAll(),
            );
          },
          enableNotifications: (enabled) async {
            final appSettings = _appSettingsDbProvider.read();

            if (appSettings == null) return;

            AppSettings newAppSettings = appSettings;

            bool isGranted = await Permission.notification.isGranted;

            if (isGranted) {
              newAppSettings =
                  appSettings.copyWith(enabledNotifications: enabled);
              emit(const NotificationsState.granted());
            } else {
              newAppSettings =
                  appSettings.copyWith(enabledNotifications: false);
              emit(const NotificationsState.denied());
            }

            await _appSettingsDbProvider.write(newAppSettings);

            NotificationsHelper.setNotifications(
              appSettings: newAppSettings,
              notificationsPlugin: _notificationsPlugin,
              userAccounts: _accountDbProvider.getAll(),
            );

            emit(
              NotificationsState.loaded(
                timestamp: DateTime.now().microsecondsSinceEpoch,
                appSettings: newAppSettings,
                allowedInSystem: isGranted,
              ),
            );
          },
          notifyAtStartOfMeasurement: (bool enabled) async {
            final appSettings = _appSettingsDbProvider.read();

            if (appSettings == null) return;

            final newAppSettings =
                appSettings.copyWith(notifyAtStartOfMeasurement: enabled);
            await _appSettingsDbProvider.write(newAppSettings);

            NotificationsHelper.setNotifications(
              appSettings: newAppSettings,
              notificationsPlugin: _notificationsPlugin,
              userAccounts: _accountDbProvider.getAll(),
            );

            emit(
              NotificationsState.loaded(
                timestamp: DateTime.now().microsecondsSinceEpoch,
                appSettings: newAppSettings,
              ),
            );
          },
          notify10MinBeforeMeasurement: (bool enabled) async {
            final appSettings = _appSettingsDbProvider.read();

            if (appSettings == null) return;

            final newAppSettings =
                appSettings.copyWith(notify10minBeforeMeasurement: enabled);
            await _appSettingsDbProvider.write(newAppSettings);
            NotificationsHelper.setNotifications(
              appSettings: newAppSettings,
              notificationsPlugin: _notificationsPlugin,
              userAccounts: _accountDbProvider.getAll(),
            );

            emit(
              NotificationsState.loaded(
                timestamp: DateTime.now().microsecondsSinceEpoch,
                appSettings: newAppSettings,
              ),
            );
          },
        );
      },
    );
  }

  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;
    debugPrint('notification payload: $payload');

    notificationsStreamController.sink.add(true);
  }

  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // display a dialog with the notification details, tap ok to go to another page
    debugPrint('notification payload: $payload');
    notificationsStreamController.sink.add(true);
  }

  AppSettings _getAppSettings() {
    final appSettings = _appSettingsDbProvider.read() ??
        AppSettings(
          themeModeLocal: buildConfig.themeMode.toLocal(),
          localLocale: buildConfig.locale.toLocal(),
        );

    return appSettings;
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('notificationTapBackground');
}
