import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/timing_day_when.dart' as tdw;
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

extension DateParse on DateTime {
  String toDateFormatLong() {
    return DateFormat('MMM d, yyyy, hh:mm a').format(toLocal());
  }

  String toDateFormatShort() {
    return DateFormat('d.M.yyyy').format(toLocal());
  }

  String toTimeShort() {
    return DateFormat('hh:mm').format(toLocal());
  }

  String toRegularDate() {
    return DateFormat('dd.MM.yyyy').format(toLocal());
  }

  WeekDay currentWeekDay() {
    final today = DateTime(year, month, day);

    return WeekDay.values[today.weekday - 1];
  }

  WeekDay tomorrowWeekDay() {
    final tomorrow = DateTime(year, month, day + 1);
    return WeekDay.values[tomorrow.weekday - 1];
  }

  DateTime fromTimeOfDay(tdw.TimeOfDay timeOfDay) {
    return DateTime(
      year,
      month,
      day,
      timeOfDay.hour,
      timeOfDay.minute,
      timeOfDay.second,
    );
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  String toDateOrDay(BuildContext context) {
    final currentDt = DateTime.now();
    final difference = daysBetween(currentDt, this).abs();

    if (difference == 0) {
      return context.locale.common_measurement_times(WhenPeriod.today.name);
    } else if (difference == 1) {
      return context.locale.common_measurement_times(WhenPeriod.tomorrow.name);
    } else {
      return toRegularDate();
    }
  }
}
