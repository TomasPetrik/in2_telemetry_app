import 'package:flutter/material.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class CalendarHelper {
  static CalendarDayPeriod getDayPeriod(DateTime dayDt) {
    final dtNow = DateTime.now().date;

    if (dayDt.isBefore(dtNow)) {
      return CalendarDayPeriod.past;
    } else if (dayDt.isAfter(dtNow)) {
      return CalendarDayPeriod.future;
    } else {
      return CalendarDayPeriod.today;
    }
  }

  static DateTime getDateByMonthsOffset(DateTime dateTime, int offset) {
    final startMonthDate = DateUtils.addMonthsToMonthDate(dateTime, 0);
    final twoMonthsAhead =
        DateUtils.addMonthsToMonthDate(startMonthDate, offset);
    return twoMonthsAhead;
  }

  static List<CalendarMonth>? getCalendarMonths(
    BuildContext context,
    DateTime fromDate,
    DateTime toDate,
  ) {
    final List<CalendarMonth> calendarMonths = [];

    final int monthsDelta = DateUtils.monthDelta(fromDate, toDate) + 1;

    for (int i = 0; i < monthsDelta; i++) {
      final offsetStartDate = DateUtils.addMonthsToMonthDate(fromDate, i);
      final offsetEndDate = DateUtils.addMonthsToMonthDate(fromDate, i + 1);
      final weekDays = getWeekDaysInMonth(
        context: context,
        currentYear: offsetStartDate.year,
        currentMonth: offsetStartDate.month,
      );
      calendarMonths.add(
        CalendarMonth(
          monthStartDate: offsetStartDate,
          monthEndDate: offsetEndDate,
          year: offsetStartDate.year,
          month: offsetStartDate.month,
          weekDays: weekDays,
        ),
      );
    }

    return calendarMonths;
  }

  static CalendarDay getToday(
    BuildContext context,
  ) {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    final weekDays = getWeekDaysInMonth(
      context: context,
      currentYear: currentYear,
      currentMonth: currentMonth,
    );

    final monthDays = weekDays.entries.fold<List<CalendarDay>>(
      [],
      (previousValue, week) => [
        ...previousValue,
        ...week.value,
      ],
    );

    final today = monthDays.firstWhere(
      (calendarDay) => calendarDay.dayPeriod == CalendarDayPeriod.today,
    );
    return today;
  }

  static CalendarMonth getCalendarMonth(
    BuildContext context,
    DateTime monthStartDate,
  ) {
    final weekDays = getWeekDaysInMonth(
      context: context,
      currentYear: monthStartDate.year,
      currentMonth: monthStartDate.month,
    );

    return CalendarMonth(
      monthStartDate: monthStartDate,
      monthEndDate: DateUtils.addMonthsToMonthDate(monthStartDate, 1),
      year: monthStartDate.year,
      month: monthStartDate.month,
      weekDays: weekDays,
    );
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

    if (weekDaysOffset > days) {
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
              startDt: dayStartDate,
              endDt: dayStartDate.add(const Duration(hours: 24)),
              dayIndex: weekDaysOffset + i,
              isDayOfCurrentMonth: i >= firstDayOffset,
              dayPeriod: getDayPeriod(dayStartDate),
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
              startDt: dayStartDate,
              endDt: dayStartDate.add(const Duration(hours: 24)),
              dayIndex: weekDaysOffset + i,
              isDayOfCurrentMonth:
                  weekDaysOffset + 1 - firstDayOffset + i <= days,
              dayPeriod: getDayPeriod(dayStartDate),
            ),
          );
        }
        return weekDays;
      }
    }
  }

  static CalendarDay? getDayByDateTime(
    CalendarMonth calendarMonth,
    DateTime dateTime,
  ) {
    final weeks = calendarMonth.weekDays.entries;
    for (final week in weeks) {
      final days = week.value;

      for (final day in days) {
        if (day.startDt.isSameDate(dateTime)) {
          return day;
        }
      }
    }

    return null;
  }
}
