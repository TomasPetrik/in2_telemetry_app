import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
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
        if (carePlan.wasExpired != true) {
          //schedule for next 30 measurements of this plan
          final nextMeasurements = Calendar.getNNextMeasurements(
            carePlans: [carePlan],
            reqCount: 30,
          );

          for (final nextMeasurement in nextMeasurements) {
            if (notifyAtStartOfMeasurement) {
              await _zonedSchedule(
                notificationId += 1,
                notificationsPlugin,
                nextMeasurement,
                carePlan,
                userAccount,
              );
            }
            if (notify10minBeforeMeasurement) {
              await _zonedSchedule(
                notificationId += 1,
                notificationsPlugin,
                nextMeasurement,
                carePlan,
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
    PlannedMeasurement nextMeasurement,
    CarePlan carePlan,
    UserAccount userAccount, [
    int? hitBeforeNMinutes,
  ]) async {
    final whenStart = nextMeasurement.whenStart
        .subtract(Duration(minutes: hitBeforeNMinutes ?? 0));

    //skip ongoing before N minutes scheduled notifications
    if (whenStart.isBefore(DateTime.now())) {
      debugPrint(
        'Skipping zoned schedule for ${whenStart.toTimeOfDay().toString()}',
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
      '${userAccount.user.fullName} - ${translactions.common_measurement} '
      '${translactions.common_measurement_types_genitive(
            carePlan.activity.measurementType.name,
          ).toLowerCase()} '
      '${nextMeasurement.whenCode != null ? translactions.common_when_code(nextMeasurement.whenCode!.name).toLowerCase() : translactions.common_at_time(nextMeasurement.whenStart.toTimeOfDay().toString())}',
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
}
