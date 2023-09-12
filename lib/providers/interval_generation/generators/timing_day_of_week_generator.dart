import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

// Do not modify without also changing TimingDayOfWeekGenerator.cs in SCSHealthPlatform
class TimingDayOfWeekGenerator {

  /// Generates weekly intervals within [currentIntervals] that occur on [weekDays]
  static List<DateTimeRange> getModifiedIntervals(
    List<WeekDay> weekDays,
    List<DateTimeRange> currentIntervals,
  ) {
    List<DateTimeRange> result = [];

    for (final currentInterval in currentIntervals) {
      for (final weekDay in weekDays) {
        final intervals = _getModifiedIntervals(currentInterval, weekDay);
        result.addAll(intervals);
      }
    }

    return result;
  }

  static List<DateTimeRange> _getModifiedIntervals(
    DateTimeRange currentInterval,
    WeekDay forDayOfWeek,
  ) {
    List<DateTimeRange> result = [];

    var start = currentInterval.start;
    while (start.isBefore(currentInterval.end)) {
      var nextMidnight = start.tomorrow;

      var currentEnd = [currentInterval.end, nextMidnight].min;
      var dayOfWeek = start.weekDay;

      if (dayOfWeek == forDayOfWeek) {
        result.add(DateTimeRange(start: start, end: currentEnd));
      }

      start = currentEnd.add(const Duration(days: 1));
    }

    return result;
  }
}
