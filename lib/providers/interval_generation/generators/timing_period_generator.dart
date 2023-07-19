import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/timing_model.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

// Do not modify without also changing TimingPeriodGenerator.cs in SCSHealthPlatform
class TimingPeriodGenerator {
  static List<DateTimeRange> getModifiedIntervals(
      TimingModel timing, List<DateTimeRange> currentIntervals) {
    if (timing.period == null || timing.periodUnit == null) {
      throw ArgumentError();
    }
    var period = timing.period!;
    var periodUnit = timing.periodUnit!;

    List<DateTimeRange> result = [];

    for (final currentInterval in currentIntervals) {
      var periodStart = currentInterval.start;

      var periodCount = 0;
      while (periodStart.isBefore(currentInterval.end)) {
        var periodEnd = _getPeriodEnd(periodStart, period, periodUnit);
        if (periodCount == 0) {
          // align upper bound for the first period, application starts with days and continues to larger time units
          DateTime? nextTimeUnitStart = switch (periodUnit) {
            TimeUnit.day => periodStart.getTomorrowMidnight(),
            TimeUnit.week => periodStart.nextWeekStart(),
            TimeUnit.month => periodStart.nextMonthStart(),
            TimeUnit.year => periodStart.nextYearStart(),
            _ => null
          };

          if (nextTimeUnitStart != null) {
            // Period end cannot be greater than the start of the next period
            periodEnd = [periodEnd, nextTimeUnitStart].min;
          }
        }
        // Period end cannot be greater than global end
        periodEnd = [periodEnd, currentInterval.end].min;
        result.add(DateTimeRange(start: periodStart, end: periodEnd));
        periodStart = periodEnd;
        periodCount++;
      }
    }

    return result;
  }

  static DateTime _getPeriodEnd(DateTime input, int period, TimeUnit periodUnit) {
    return switch (periodUnit) {
      TimeUnit.hour => input.add(Duration(hours: period)),
      TimeUnit.day => input.add(Duration(days: period)),
      TimeUnit.week => input.add(Duration(days: period * 7)),
      TimeUnit.month => input.copyWith(month: input.month + 1),
      TimeUnit.year => input.copyWith(year: input.year + 1),
    };
  }
}
