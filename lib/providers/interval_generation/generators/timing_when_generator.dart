import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/when_model.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

// Do not modify without also changing TimingWhenGenerator.cs in SCSHealthPlatform
class TimingWhenGenerator {
  static List<DateTimeRange> getModifiedIntervals(
    List<WhenModel> whenTimings,
    List<DateTimeRange> currentIntervals, {
    DateTime? startLimit,
    DateTime? endLimit,
  }) {
    List<DateTimeRange> result = [];

    for (final currentInterval in currentIntervals) {
      for (final when in whenTimings) {
        final intervals = _generateIntervals(
          when.start.toDuration(),
          when.end.toDuration(),
          currentInterval,
          when.whenCode,
          startLimit: startLimit,
          endLimit: endLimit,
        );
        result.addAll(intervals);
      }
    }

    return result;
  }

  /// Generates measurement intervals.
  ///
  /// [startTime] is the start of the selected when code, [endTime] is its end.
  /// All generated intervals will occur at least partially within [intervalBounds].
  /// Intervals will be trimmed to begin no sooner than [startLimit], end no later than [endLimit].
  static List<DateTimeRange> _generateIntervals(
    Duration startTime,
    Duration endTime,
    DateTimeRange intervalBounds,
    WhenCode code, {
    DateTime? startLimit,
    DateTime? endLimit,
  }) {
    if (code == WhenCode.night && startTime > endTime) {
      return _generateOvernightIntervals(
        startTime,
        endTime,
        intervalBounds,
        startLimit: startLimit,
        endLimit: endLimit,
      );
    }

    return _generateIntervalsInSingleDay(
      startTime,
      endTime,
      intervalBounds,
      startLimit: startLimit,
      endLimit: endLimit,
    );
  }

  /// Generates measurement intervals that occur across two consecutive days (intervals cross midnight).
  ///
  /// [startTime] is the start of the selected when code, [endTime] is its end.
  /// All generated intervals will occur at least partially within [intervalBounds].
  /// Intervals will be trimmed to begin no sooner than [startLimit], end no later than [endLimit].
  static List<DateTimeRange> _generateOvernightIntervals(
    Duration startTime,
    Duration endTime,
    DateTimeRange intervalBounds, {
    DateTime? startLimit,
    DateTime? endLimit,
  }) {
    List<DateTimeRange> result = [];

    var start = intervalBounds.start;

    while (start.isBefore(intervalBounds.end)) {
      final midnight = start.getTomorrowMidnight();
      final currentEnd = [midnight, intervalBounds.end].min;

      final startDateTime = start.replaceTime(startTime);
      final endDateTime = midnight.replaceTime(endTime);

      var startLimits = [start, startDateTime];
      if (startLimit != null) {
        startLimits.add(startLimit);
      }

      // Limit end to next midnight or end of interval
      var resultEnd = [currentEnd, endDateTime].max;
      if (endLimit != null) {
        resultEnd = [resultEnd, endLimit].min;
      }

      var resultStart = startLimits.max;

      // Filter out zero-length intervals and out-of-range intervals
      if (start.isBeforeOrAt(resultStart) &&
          resultStart.isBeforeOrAt(intervalBounds.end) &&
          start.isBefore(resultEnd)) {
        if (resultStart.isBefore(resultEnd)) {
          result.add(DateTimeRange(start: resultStart, end: resultEnd));
        }
      }

      start = currentEnd;
    }

    return result;
  }

  /// Generates measurement intervals that occur within a single day (intervals cross midnight).
  ///
  /// [startTime] is the start of the selected when code, [endTime] is its end.
  /// All generated intervals will occur at least partially within [intervalBounds].
  /// Intervals will be trimmed to begin no sooner than [startLimit], end no later than [endLimit].
  static List<DateTimeRange> _generateIntervalsInSingleDay(
    Duration startTime,
    Duration endTime,
    DateTimeRange intervalBounds, {
    DateTime? startLimit,
    DateTime? endLimit,
  }) {
    List<DateTimeRange> result = [];

    var start = intervalBounds.start;

    while (start.isBefore(intervalBounds.end)) {
      final midnight = start.getTomorrowMidnight();
      final currentEnd = [midnight, intervalBounds.end].min;

      final startDateTime = start.replaceTime(startTime);
      final endDateTime = start.replaceTime(endTime);

      var startLimits = [start, startDateTime];
      if (startLimit != null) {
        startLimits.add(startLimit);
      }

      var endLimits = [currentEnd, endDateTime];
      if (endLimit != null) {
        endLimits.add(endLimit);
      }

      var resultStart = startLimits.max;
      var resultEnd = endLimits.min;

      // Filter out zero-length intervals and out-of-range intervals
      if (start.isBeforeOrAt(resultStart) &&
          resultStart.isBeforeOrAt(intervalBounds.end) &&
          start.isBefore(resultEnd)) {
        if (resultStart.isBefore(resultEnd)) {
          result.add(DateTimeRange(start: resultStart, end: resultEnd));
        }
      }

      start = currentEnd;
    }

    return result;
  }
}
