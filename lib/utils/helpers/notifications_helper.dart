import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/data/providers/user_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationsHelper {
  static Future<void> removeUserNotifications({
    required final FlutterLocalNotificationsPlugin notificationsPlugin,
    required final UserModel userAccount,
  }) async {
    for (final notificationId in userAccount.notificationIds) {
      await notificationsPlugin.cancel(notificationId);
      debugPrint('cancelled $notificationId');
    }

    for (final representedPerson in userAccount.representedPeople) {
      for (final notificationId in representedPerson.notificationIds) {
        await notificationsPlugin.cancel(notificationId);
        debugPrint('cancelled $notificationId');
      }
    }
  }

  static Future<void> setNotifications({
    required final FlutterLocalNotificationsPlugin notificationsPlugin,
    required final List<UserModel> userAccounts,
    required final AppSetting appSettings,
  }) async {
    final carePlanDbProvider = getIt<CarePlanDbProvider>();
    final userDbProvider = getIt<UserDbProvider>();

    //clear all notifications set first
    await notificationsPlugin.cancelAll();
    debugPrint('cancelled all notifications');

    if (!appSettings.enableNotifications) {
      return;
    }

    final notifyAtStartOfMeasurement = appSettings.notifyAtStartOfMeasurement == true;
    final notify10minBeforeMeasurement = appSettings.notify10minBeforeMeasurement == true;

    if (!notifyAtStartOfMeasurement && !notify10minBeforeMeasurement) {
      return;
    }

    //set notifications for all active / no active users for following 30 measurements per each plan

    int notificationId = 100;
    for (final userAccount in userAccounts) {
      final List<int> notificationIds = [];

      final carePlans = await carePlanDbProvider.getByUser(userAccount.id);
      final now = DateTime.now();

      for (final carePlan in carePlans) {
        //only for current active plans
        if (carePlan.versions.any((x) => x.scheduledStart.isBefore(now)) &&
            (carePlan.versions.last.scheduledEnd?.isAfter(now) ?? true)) {
          //schedule for next 30 measurements of this plan
          final nextMeasurements = Calendar.getNScheduledMeasurements(
            carePlans: [carePlan],
            reqCount: 30,
          );

          final List<Future> tasks = [];

          for (final nextMeasurement in nextMeasurements) {
            if (notifyAtStartOfMeasurement) {
              notificationIds.add(notificationId += 1);
              tasks.add(
                _zonedSchedule(
                  notificationIds.last,
                  notificationsPlugin,
                  nextMeasurement,
                  userAccount,
                ),
              );
            }
            if (notify10minBeforeMeasurement) {
              notificationIds.add(notificationId += 1);
              tasks.add(
                _zonedSchedule(
                  notificationIds.last,
                  notificationsPlugin,
                  nextMeasurement,
                  userAccount,
                  10,
                ),
              );
            }
          }

          await Future.wait(tasks);
        }
      }

      await userDbProvider.updateUser(userAccount.id, UsersCompanion(notificationIds: Value(notificationIds)));

      debugPrint(
        'created ${userAccount.notificationIds.length} notifications for ${userAccount.fullName}',
      );
    }
  }

  static Future<void> _zonedSchedule(
    int id,
    FlutterLocalNotificationsPlugin notificationsPlugin,
    PlannedMeasurement plannedMeasurement,
    UserModel userAccount, [
    int? hitBeforeNMinutes,
  ]) async {
    final whenStart = plannedMeasurement.whenStart.subtract(Duration(minutes: hitBeforeNMinutes ?? 0));

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
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static String _getBodyMessage(
    UserModel userAccount,
    PlannedMeasurement plannedMeasurement,
  ) {
    String message = '';
    message += '${userAccount.fullName} - ${localization.common_measurement} ';
    message += '${localization.common_measurement_types_genitive(
          plannedMeasurement.carePlan.activity.measurementType.name,
        ).toLowerCase()} ';

    if (CarePlanHelper.isPeriodical(plannedMeasurement.carePlan)) {
      message += localization.notification_periodical_frequency_from_to(
        plannedMeasurement.carePlan.versions.last.frequency,
        plannedMeasurement.isLongPeriod
            ? plannedMeasurement.whenStart.dateFormatLong
            : plannedMeasurement.whenStart.toLocal().toTimeOfDay().toString(),
        plannedMeasurement.isLongPeriod
            ? plannedMeasurement.whenEnd.dateFormatLong
            : plannedMeasurement.whenEnd.toLocal().toTimeOfDay().toString(),
      );
    } else {
      if (plannedMeasurement.whenCode != null) {
        message += localization.common_when_code(plannedMeasurement.whenCode!.name).toLowerCase();
      }
      message += ' ${localization.common_at_time(
        plannedMeasurement.whenStart.toTimeOfDay().toString(),
      )}';
    }

    return message;
  }
}
