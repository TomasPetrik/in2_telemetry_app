import 'package:flutter/material.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class CalendarHelper {
  static CalendarDayPeriod getDayPeriod(DateTime dayDt) {
    final dtNow = DateTime.now().getTodayMidnight();

    if (dayDt.isBefore(dtNow)) {
      return CalendarDayPeriod.past;
    } else if (dayDt.isAfter(dtNow)) {
      return CalendarDayPeriod.future;
    } else {
      return CalendarDayPeriod.today;
    }
  }

  static List<CalendarMonth>? getCalendarMonths(
    BuildContext context,
    DateTime fromDate,
    DateTime toDate,
  ) {
    final List<CalendarMonth> calendarMonths = [];

    final int monthsDelta = DateUtils.monthDelta(fromDate, toDate) + 1;

    for (int i = 0; i < monthsDelta; i++) {
      final offsetDate = DateUtils.addMonthsToMonthDate(fromDate, i);
      final weekDays = getWeekDaysInMonth(
        context: context,
        currentYear: offsetDate.year,
        currentMonth: offsetDate.month,
      );
      calendarMonths.add(
        CalendarMonth(
          year: offsetDate.year,
          month: offsetDate.month,
          weekDays: weekDays,
        ),
      );
    }

    return calendarMonths;
  }

  static Map<int, List<CalendarDay>> getWeekDaysInMonth({
    required BuildContext context,
    required int currentYear,
    required int currentMonth,
  }) {
    final Map<int, List<CalendarDay>> weekDays = {};

    int week = 0;
    while (true) {
      final daysInWeek = getDaysInWeek(
        context,
        currentYear,
        currentMonth,
        week,
      );
      if (daysInWeek != null) {
        weekDays[week] = daysInWeek;
      } else {
        break;
      }

      week += 1;
    }
    return weekDays;
  }

  static List<CalendarDay>? getDaysInWeek(
    BuildContext context,
    int year,
    int month,
    int week,
  ) {
    final days = DateUtils.getDaysInMonth(year, month);
    final firstDayOffset = DateUtils.firstDayOffset(
      year,
      month,
      MaterialLocalizations.of(context),
    );

    final weekDaysOffset = week * 7;

    if (weekDaysOffset + 1 > days) {
      return null;
    } else {
      if (week == 0) {
        final startDate =
            DateTime(year, month).subtract(Duration(days: firstDayOffset));
        List<CalendarDay> weekDays = [];
        for (int i = 0; i < 7; i++) {
          final dayStartDate = startDate.add(Duration(days: i));
          weekDays.add(
            CalendarDay(
              dt: dayStartDate,
              dayIndex: i,
              isDayOfCurrentMonth: i >= firstDayOffset,
              dayPeriod: getDayPeriod(dayStartDate),
              carePlansEvaluation: 50,
            ),
          );
        }
        return weekDays;
      } else {
        final startDate = DateTime(
          year,
          month,
          weekDaysOffset + 1,
        ).subtract(
          Duration(days: firstDayOffset),
        ); //because days starts from 1

        List<CalendarDay> weekDays = [];
        for (int i = 0; i < 7; i++) {
          final dayStartDate = startDate.add(Duration(days: i));
          weekDays.add(
            CalendarDay(
              dt: dayStartDate,
              dayIndex: i,
              isDayOfCurrentMonth:
                  weekDaysOffset + 1 - firstDayOffset + i <= days,
              dayPeriod: getDayPeriod(dayStartDate),
              plannedMeasurements: 4,
            ),
          );
        }
        return weekDays;
      }
    }
  }
}
