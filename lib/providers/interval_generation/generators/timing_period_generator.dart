import 'dart:core';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/timing_model.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

// Do not modify without also changing TimingPeriodGenerator.cs in SCSHealthPlatform
class TimingPeriodGenerator {
  static List<DateTimeRange> getIntervals(
    TimingModel timing,
    DateTime from,
    DateTime to,
    DateTime planStart, {
    DateTime? startLimit,
    DateTime? endLimit,
  }) {
    if (timing.period == null || timing.periodUnit == null) {
      throw ArgumentError();
    }
    var period = timing.period!;
    var periodUnit = timing.periodUnit!;

    List<DateTimeRange> result = [];

    var periodStart =
        _getFirstRelevantIntervalStart(planStart, from, period, periodUnit);

    var periodCount = 0;
    while (periodStart.isBefore(to)) {
      var periodEnd = _getPeriodEnd(periodStart, period, periodUnit);

      if (periodCount == 0) {
        final secondIntervalStart =
            _getSecondIntervalStart(periodStart, period, periodUnit);
        periodEnd = [periodEnd, secondIntervalStart].min;
      }

      final intervalStart =
          startLimit != null ? [startLimit, periodStart].max : periodStart;
      final intervalEnd =
          endLimit != null ? [endLimit, periodEnd].min : periodEnd;

      if (intervalStart.isBefore(intervalEnd)) {
        result.add(DateTimeRange(start: intervalStart, end: intervalEnd));
      }

      periodStart = periodEnd;
      periodCount++;
    }

    return result;
  }

  /// Calculates the start of the second interval
  /// First intervals (except when [periodUnit] is [TimeUnitContract.hour]) do not last a multiple of [periodUnit].
  /// Instead, the first period's end is aligned to a multiple of [periodUnit]
  /// For example, the first interval for a daily period doesn't end after a day. Instead it ends at the start (midnight) of the closest day.
  static DateTime _getSecondIntervalStart(
    DateTime periodStart,
    int period,
    TimeUnitContract periodUnit,
  ) {
    // First, align the interval with the start of a period unit (next midnight / start of next month / ...)
    final alignedInterval = switch (periodUnit) {
      TimeUnitContract.hour => periodStart.add(const Duration(hours: 1)),
      TimeUnitContract.day => periodStart.tomorrow,
      TimeUnitContract.week => periodStart.nextWeekStart,
      TimeUnitContract.month => periodStart.nextMonthStart,
      TimeUnitContract.year => periodStart.nextYearStart,
    };

    // We've "used up" one period by aligning with a period unit. Now we'll add the remaining periods.
    var result = _getPeriodEnd(alignedInterval, period - 1, periodUnit);

    return result;
  }

  /// Calculates the start of the first interval which ends after [requestedStart].
  static DateTime _getFirstRelevantIntervalStart(
    DateTime planStart,
    DateTime requestedStart,
    int period,
    TimeUnitContract periodUnit,
  ) {
    // If the plan starts in the future, the first relevant interval starts when the plan starts
    if (requestedStart.isAtSameMomentAs(planStart) ||
        requestedStart.isBefore(planStart)) {
      return planStart;
    }

    // The first interval is a special case (it's shorter) So we'll handle it separately.
    // If it ends after requestedStart, it's the interval we're looking for.
    // Otherwise we carry on, starting with the second interval.
    final firstIntervalEnd =
        _getSecondIntervalStart(planStart, period, periodUnit);
    if (firstIntervalEnd.isAfter(requestedStart)) {
      return planStart;
    }

    return _getFirstRelevantIntervalStartImpl(
      firstIntervalEnd,
      requestedStart,
      period,
      periodUnit,
    );
  }

  /// Calculates the start of the first interval which ends after [requestedStart]
  static DateTime _getFirstRelevantIntervalStartImpl(
    DateTime planStart,
    DateTime requestedStart,
    int period,
    TimeUnitContract periodUnit,
  ) {
    var current = planStart;
    DateTime previous;

    do {
      previous = current;

      current = _getPeriodEnd(current, period, periodUnit);
    } while (current.isBefore(requestedStart));

    return previous;
  }

  static DateTime _getPeriodEnd(
    DateTime input,
    int period,
    TimeUnitContract periodUnit,
  ) {
    return switch (periodUnit) {
      TimeUnitContract.hour => input.add(Duration(hours: period)),
      TimeUnitContract.day => input.add(Duration(days: period)),
      TimeUnitContract.week => input.add(Duration(days: period * 7)),
      TimeUnitContract.month => input.copyWith(month: input.month + 1),
      TimeUnitContract.year => input.copyWith(year: input.year + 1),
    };
  }
}
