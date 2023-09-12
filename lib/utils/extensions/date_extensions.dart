import 'package:intl/intl.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart' as tdw;
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/utils/extensions/string_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

extension DateParse on DateTime {

  String get dateFormatLong => DateFormat('d. M. yyyy - HH:mm').format(toLocal());

  String get timeFormatShort => DateFormat('HH:mm').format(toLocal());

  String get dateFormatShort => DateFormat('dd.MM').format(toLocal());

  String get dateFormat => //toRegularDate() {
    DateFormat('dd.MM.yyyy').format(toLocal());

  DateTime get date => DateTime(year, month, day);

  // to prevent DST skew, add one day to UTC and then return local time of it
  DateTime get yesterday {
    final utcDate = DateTime.utc(year, month, day);
    final yesterday = utcDate.subtract(const Duration(days: 1));
    return DateTime(yesterday.year, yesterday.month, yesterday.day);
  }

  // to prevent DST skew, add one day to UTC and then return local time of it
  DateTime get tomorrow {
    final utcDate = DateTime.utc(year, month, day);
    final tomorrow = utcDate.add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  bool get isToday => DateTime.now().date == date;

  bool get wasYesterday => DateTime.now().yesterday == date;

  WeekDay get weekDay => WeekDay.values[date.weekday - 1];

  DateTime get startOfDay => date;

  DateTime get endOfDay => tomorrow;

  tdw.DailyTime toTimeOfDay() => tdw.DailyTime(hour, minute, second);

  bool isSameDate(DateTime other) => year == other.year && month == other.month && day == other.day;

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
      return dateFormat;
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
      return dateFormat;
    }
  }

  DateTime get nextWeekStart {
    var nextWeekStartWithTime = add(Duration(days: 7 + weekday - 1));
    return nextWeekStartWithTime.date;
  }

  DateTime get nextMonthStart {
    return DateTime(year, month + 1);
  }

  DateTime get nextYearStart {
    return DateTime(year + 1);
  }

  DateTime replaceTime(Duration timeOfDay) {
    return date.add(timeOfDay);
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
