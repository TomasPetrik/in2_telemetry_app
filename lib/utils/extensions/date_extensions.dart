import 'package:intl/intl.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart' as tdw;
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/utils/extensions/string_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

extension DateParse on DateTime {
  String toDateFormatLong() {
    return DateFormat('d. M. yyyy - HH:mm').format(toLocal());
  }

  String toTimeShort() {
    return DateFormat('HH:mm').format(toLocal());
  }

  String toDateShort() {
    return DateFormat('dd.MM').format(toLocal());
  }

  String toRegularDate() {
    return DateFormat('dd.MM.yyyy').format(toLocal());
  }

  bool isToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(year, month, day);
    final isToday = today == checkDate;
    return isToday;
  }

  bool wasYesterday() {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final checkDate = DateTime(year, month, day);
    final wasYesterday = yesterday == checkDate;
    return wasYesterday;
  }

  WeekDay toWeekDay() {
    final today = DateTime(year, month, day);

    return WeekDay.values[today.weekday - 1];
  }

  WeekDay tomorrowWeekDay() {
    final today = DateTime(year, month, day);
    final tomorrow = today.add(const Duration(days: 1));
    return WeekDay.values[tomorrow.weekday - 1];
  }

  WeekDay yesterdayWeekDay() {
    final today = DateTime(year, month, day);
    final yesterday = today.subtract(const Duration(days: 1));
    return WeekDay.values[yesterday.weekday - 1];
  }

  DateTime getYesterdayMidnight() {
    final today = DateTime(year, month, day);
    final yesterdayMidnight = today.subtract(const Duration(days: 1));
    return yesterdayMidnight;
  }

  DateTime getTomorrowMidnight() {
    final today = DateTime(year, month, day);
    final tomorrowMidnight = today.add(const Duration(days: 1));
    return tomorrowMidnight;
  }

  DateTime getTodayMidnight() {
    final today = DateTime(year, month, day);
    return today;
  }

  DateTime getStartOfDay() {
    final startDayDt = DateTime(year, month, day, 0, 0, 0, 0, 0);
    return startDayDt;
  }

  DateTime getEndOfDay() {
    final endDayDt =
        DateTime(year, month, day, 0, 0, 0, 0, 0).add(const Duration(days: 1));
    return endDayDt;
  }

  tdw.DailyTime toTimeOfDay() {
    return tdw.DailyTime(hour, minute, second);
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  String toDateOrDay() {
    final currentDt = DateTime.now();
    final difference = daysBetween(currentDt, this);

    if (difference == -1) {
      return localization.common_measurement_times(WhenPeriod.yesterday.name);
    }
    if (difference == 0) {
      return localization.common_measurement_times(WhenPeriod.today.name);
    } else if (difference == 1) {
      return localization.common_measurement_times(WhenPeriod.tomorrow.name);
    } else {
      return toRegularDate();
    }
  }

  String toHistoricalDateOrDay() {
    final currentDt = DateTime.now();
    final difference = daysBetween(currentDt, this);

    if (difference == -1) {
      return localization
          .common_when_day_name(WhenPeriod.yesterday.name)
          .capitalize();
    }
    if (difference == 0) {
      return localization
          .common_when_day_name(WhenPeriod.today.name)
          .capitalize();
    } else {
      return toRegularDate();
    }
  }

  DateTime nextWeekStart() {
    var nextWeekStartWithTime = add(Duration(days: 7 + weekday - 1));
    return nextWeekStartWithTime.getDate();
  }

  DateTime getDate() {
    return DateTime(year, month, day);
  }

  DateTime nextMonthStart() {
    return DateTime(year, month + 1);
  }

  DateTime nextYearStart() {
    return DateTime(year + 1);
  }

  DateTime replaceTime(Duration timeOfDay) {
    return getStartOfDay().add(timeOfDay);
  }

  bool isBeforeOrAt(DateTime other) {
    return isBefore(other) || isAtSameMomentAs(other);
  }

  bool isAfterOrAt(DateTime other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }
}

DateTime toLocalDate(String dtUtc) {
  final dtLocal = DateTime.parse(dtUtc).toLocal();
  return dtLocal;
}

DateTime? toLocalDateNullable(String? dtUtc) {
  if (dtUtc == null) return null;
  final dtLocal = DateTime.parse(dtUtc).toLocal();
  return dtLocal;
}
