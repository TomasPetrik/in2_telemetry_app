import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_event.dart';
import 'package:scalesoft_app/bloc/notifications/notifications_state.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/providers/settings_db_provider.dart';
import 'package:scalesoft_app/data/providers/user_db_provider.dart';
import 'package:scalesoft_app/utils/helpers/notifications_helper.dart';

@singleton
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final UserDbProvider _userDbProvider;
  final SettingsDbProvider _settingsDbProvider;

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  final StreamController<bool> notificationsStreamController = StreamController<bool>.broadcast();

  bool requestedForPermission = false;

  NotificationsBloc(
    this._userDbProvider,
    this._settingsDbProvider,
  ) : super(const NotificationsState.init()) {
    on<NotificationsEvent>(
      (event, emit) async {
        await event.when(
          initPlugin: () async {
            const AndroidInitializationSettings initializationSettingsAndroid =
                AndroidInitializationSettings('ic_launcher_foreground');
            final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
              onDidReceiveLocalNotification: onDidReceiveLocalNotification,
            );
            final InitializationSettings initializationSettings = InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsDarwin,
            );
            await _notificationsPlugin.initialize(
              initializationSettings,
              onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
              onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
            );

            final appSettings = await _settingsDbProvider.getSettings();

            NotificationsHelper.setNotifications(
              appSettings: appSettings,
              notificationsPlugin: _notificationsPlugin,
              userAccounts: await _userDbProvider.getAll(),
            );
          },
          initSettings: () async {
            //get most recent permission status of notification
            bool isGranted = await Permission.notification.isGranted;

            final appSettings = isGranted
                ? await _settingsDbProvider.getSettings()
                : await _settingsDbProvider.updateAppSettings(
                    const AppSettingsCompanion(enableNotifications: Value(false)),
                  );

            emit(
              NotificationsState.loaded(
                timestamp: DateTime.now().microsecondsSinceEpoch,
                appSettings: appSettings,
                allowedInSystem: isGranted,
              ),
            );
          },
          setNotificationsBySystemSettings: () async {
            bool isGranted = await Permission.notification.isGranted;

            await _settingsDbProvider.updateAppSettings(AppSettingsCompanion(enableNotifications: Value(isGranted)));

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
          setNotifications: () async {
            final appSettings = await _settingsDbProvider.getSettings();

            NotificationsHelper.setNotifications(
              appSettings: appSettings,
              notificationsPlugin: _notificationsPlugin,
              userAccounts: await _userDbProvider.getAll(),
            );
          },
          enableNotifications: (enabled) async {
            bool isGranted = await Permission.notification.isGranted;

            AppSetting newAppSettings;

            if (isGranted) {
              newAppSettings = await _settingsDbProvider
                  .updateAppSettings(AppSettingsCompanion(enableNotifications: Value(enabled)));
              emit(const NotificationsState.granted());
            } else {
              newAppSettings = await _settingsDbProvider.updateAppSettings(
                const AppSettingsCompanion(enableNotifications: Value(false)),
              );
              emit(const NotificationsState.denied());
            }

            NotificationsHelper.setNotifications(
              appSettings: newAppSettings,
              notificationsPlugin: _notificationsPlugin,
              userAccounts: await _userDbProvider.getAll(),
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
            final newAppSettings = await _settingsDbProvider
                .updateAppSettings(AppSettingsCompanion(notifyAtStartOfMeasurement: Value(enabled)));

            NotificationsHelper.setNotifications(
              appSettings: newAppSettings,
              notificationsPlugin: _notificationsPlugin,
              userAccounts: await _userDbProvider.getAll(),
            );

            emit(
              NotificationsState.loaded(
                timestamp: DateTime.now().microsecondsSinceEpoch,
                appSettings: newAppSettings,
                allowedInSystem: true,
              ),
            );
          },
          notify10MinBeforeMeasurement: (bool enabled) async {
            final newAppSettings = await _settingsDbProvider
                .updateAppSettings(AppSettingsCompanion(notify10minBeforeMeasurement: Value(enabled)));
            NotificationsHelper.setNotifications(
              appSettings: newAppSettings,
              notificationsPlugin: _notificationsPlugin,
              userAccounts: await _userDbProvider.getAll(),
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
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('notificationTapBackground');
}
