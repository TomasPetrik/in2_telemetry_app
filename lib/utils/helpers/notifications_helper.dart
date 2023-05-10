import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scalesoft_app/model/app_settings.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationsHelper {
  static Future<void> setNotifications({
    required final FlutterLocalNotificationsPlugin notificationsPlugin,
    required final List<UserAccount> userAccounts,
    required final AppSettings? appSettings,
  }) async {
    //clear all notifications set first
    notificationsPlugin.cancelAll();

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

    int notificationId = 100;
    for (final userAccount in userAccounts) {
      for (final carePlan in userAccount.carePlans!) {
        //only for current active plans
        if (carePlan.wasExpired != true &&
            carePlan.started &&
            !carePlan.fihisned) {
          //schedule for next 30 measurements of this plan
          final nextMeasurements = Calendar.getNScheduledMeasurements(
            carePlans: [carePlan],
            reqCount: 30,
          );

          for (final nextMeasurement in nextMeasurements) {
            if (notifyAtStartOfMeasurement) {
              await _zonedSchedule(
                notificationId += 1,
                notificationsPlugin,
                nextMeasurement,
                userAccount,
              );
            }
            if (notify10minBeforeMeasurement) {
              await _zonedSchedule(
                notificationId += 1,
                notificationsPlugin,
                nextMeasurement,
                userAccount,
                10,
              );
            }
          }
        }
      }
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
      translactions.common_telemedicine,
      _getBodyMessage(userAccount, plannedMeasurement),
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scalesoft_android',
          'scalesoft_android_channel',
          channelDescription: 'scalesoft_android_channel_description',
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
        '${userAccount.user.fullName} - ${translactions.common_measurement} ';
    message += '${translactions.common_measurement_types_genitive(
          plannedMeasurement.carePlan.activity.measurementType.name,
        ).toLowerCase()} ';

    if (plannedMeasurement.carePlan.isPeriodical) {
      message += translactions.notification_periodical_frequency_from_to(
        plannedMeasurement.carePlan.frequency,
        plannedMeasurement.isLongPeriod
            ? plannedMeasurement.whenStart.toDateFormatLong()
            : plannedMeasurement.whenStart.toLocal().toTimeOfDay().toString(),
        plannedMeasurement.isLongPeriod
            ? plannedMeasurement.whenEnd.toDateFormatLong()
            : plannedMeasurement.whenEnd.toLocal().toTimeOfDay().toString(),
      );
    } else {
      if (plannedMeasurement.whenCode != null) {
        message += translactions
            .common_when_code(plannedMeasurement.whenCode!.name)
            .toLowerCase();
      }
      message += translactions.common_at_time(
        plannedMeasurement.whenStart.toTimeOfDay().toString(),
      );
    }

    return message;
  }
}
