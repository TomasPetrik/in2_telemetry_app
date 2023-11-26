import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationsHelper {
  static Future<void> removeUserNotifications({
    required final FlutterLocalNotificationsPlugin notificationsPlugin,
    required final UserAccount userAccount,
  }) async {
    if (userAccount.notificationsIds == null ||
        userAccount.notificationsIds?.isEmpty == true) {
      return;
    }
    for (final notificationId in userAccount.notificationsIds!) {
      await notificationsPlugin.cancel(notificationId);
      debugPrint('cancelled $notificationId');
    }
  }

  static Future<void> setNotifications({
    required final FlutterLocalNotificationsPlugin notificationsPlugin,
    required final List<UserAccount> userAccounts,
    required final AppSettings? appSettings,
  }) async {
    int getNotificationId(int base, int offset) {
      return base + offset;
    }

    //clear all notifications set first
    await notificationsPlugin.cancelAll();
    debugPrint('cancelled all notifications');

    if (appSettings?.enabledNotifications != true) {
      return;
    }

    final notifyAtStartOfMeasurement =
        appSettings?.notifyAtStartOfMeasurement == true;
    final notify10minBeforeMeasurement =
        appSettings?.notify10minBeforeMeasurement == true;

    if (!notifyAtStartOfMeasurement && !notify10minBeforeMeasurement) {
      return;
    }

    //set notifications for all active / no active users for following 30 measurements per each plan

    for (final userAccount in userAccounts) {
      final notificationId =
          DateTime.now().millisecondsSinceEpoch.toUnsigned(32);
      userAccount.notificationBaseId ??= notificationId;
      int notificationIdOffset = 0;
      final List<int> notificationIds = [];

      for (final carePlan in userAccount.carePlans!) {
        //only for current active plans
        if (carePlan.wasExpired != true &&
            carePlan.started &&
            !carePlan.finished) {
          //schedule for next 30 measurements of this plan
          final nextMeasurements = Calendar.getNScheduledMeasurements(
            carePlans: [carePlan],
            reqCount: 30,
          );

          for (final nextMeasurement in nextMeasurements) {
            if (notifyAtStartOfMeasurement) {
              final notificationId = getNotificationId(
                userAccount.notificationBaseId!,
                notificationIdOffset++,
              );
              notificationIds.add(notificationId);
              await _zonedSchedule(
                notificationId,
                notificationsPlugin,
                nextMeasurement,
                userAccount,
              );
            }
            if (notify10minBeforeMeasurement) {
              final notificationId = getNotificationId(
                userAccount.notificationBaseId!,
                notificationIdOffset++,
              );
              notificationIds.add(notificationId);
              await _zonedSchedule(
                notificationId,
                notificationsPlugin,
                nextMeasurement,
                userAccount,
                10,
              );
            }
          }
        }
      }

      userAccount.notificationsIds = notificationIds;
       debugPrint(
        'created ${userAccount.notificationsIds!.length} notifications for ${userAccount.user.fullName}',
      );
    }
  }

  static Future<void> _zonedSchedule(
    int id,
    FlutterLocalNotificationsPlugin notificationsPlugin,
    PlannedMeasurement plannedMeasurement,
    UserAccount userAccount, [
    int? hitBeforeNMinutes,
  ]) async {
    final whenStart = plannedMeasurement.whenStart
        .subtract(Duration(minutes: hitBeforeNMinutes ?? 0));

    //skip ongoing before N minutes scheduled notifications
    if (whenStart.isBefore(DateTime.now())) {
      debugPrint(
        'Skipping ongoing measurement to be scheduled for notification [${whenStart.toTimeOfDay().toString()}]',
      );
      return;
    }

    /*
    debugPrint(
      'zoned schedule $id for ${whenStart.toIso8601String()} ',
    );
    */

    final scheduledTime = tz.TZDateTime.from(whenStart, tz.local);
    await notificationsPlugin.zonedSchedule(
      id,
      localization.common_app_name,
      _getBodyMessage(userAccount, plannedMeasurement),
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scalesoft_android',
          'scalesoft_android_channel',
          channelDescription: 'scalesoft_android_channel_description',
          color: Color.fromARGB(255, 33, 100, 123),
          icon: "ic_notification_foreground",
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
    );
  }

  static String _getBodyMessage(
    UserAccount userAccount,
    PlannedMeasurement plannedMeasurement,
  ) {
    String message = '';
    message +=
        '${userAccount.user.fullName} - ${localization.common_measurement} ';
    message += '${localization.common_measurement_types_genitive(
          plannedMeasurement.carePlan.activity.measurementType.name,
        ).toLowerCase()} ';

    if (plannedMeasurement.carePlan.isPeriodical) {
      message += localization.notification_periodical_frequency_from_to(
        plannedMeasurement.carePlan.frequency,
        plannedMeasurement.isLongPeriod
            ? plannedMeasurement.whenStart.dateFormatLong
            : plannedMeasurement.whenStart.toLocal().toTimeOfDay().toString(),
        plannedMeasurement.isLongPeriod
            ? plannedMeasurement.whenEnd.dateFormatLong
            : plannedMeasurement.whenEnd.toLocal().toTimeOfDay().toString(),
      );
    } else {
      if (plannedMeasurement.whenCode != null) {
        message += localization
            .common_when_code(plannedMeasurement.whenCode!.name)
            .toLowerCase();
      }
      message += ' ${localization.common_at_time(
        plannedMeasurement.whenStart.toTimeOfDay().toString(),
      )}';
    }

    return message;
  }
}
