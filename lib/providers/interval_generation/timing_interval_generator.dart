import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/timing_model.dart';
import 'package:scalesoft_app/providers/interval_generation/generators/timing_day_of_week_generator.dart';
import 'package:scalesoft_app/providers/interval_generation/generators/timing_period_generator.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/evaluation_interval_model.dart';
import 'package:scalesoft_app/providers/interval_generation/generators/timing_time_of_day_generator.dart';
import 'package:scalesoft_app/providers/interval_generation/generators/timing_when_generator.dart';

class TimingIntervalGenerator {
  /// Generates measurement intervals.
  ///
  /// All generated intervals will occur at least partially between [start] and [end] [intervalBounds].
  /// Intervals will be trimmed to begin no sooner than [startLimit], end no later than [endLimit].
  /// Usually, these limits should most likely come from a care plan version's activeFrom, activeTo
  static List<EvaluationIntervalModel> generateIntervalsByRangeAndTiming(
    TimingModel timing,
    DateTime start,
    DateTime end, {
    DateTime? startLimit,
    DateTime? endLimit,
  }) {
    // TODO: timezones?

    if (start.isAtSameMomentAs(end) || start.isAfter(end)) {
      return [];
    }

    var intervals = [DateTimeRange(start: start, end: end)];

    intervals = TimingPeriodGenerator.getModifiedIntervals(timing, intervals);

    if (timing.weekDays?.isNotEmpty == true) {
      intervals = TimingDayOfWeekGenerator.getModifiedIntervals(
        timing.weekDays!,
        intervals,
      );
    }

    if (timing.timesOfDay?.isNotEmpty == true) {
      intervals = TimingTimeOfDayGenerator.getModifiedIntervals(
        timing.timesOfDay!,
        intervals,
        startLimit: startLimit,
        endLimit: endLimit,
      );
    }

    if (timing.when?.isNotEmpty == true) {
      intervals = TimingWhenGenerator.getModifiedIntervals(
        timing.when!,
        intervals,
        startLimit: startLimit,
        endLimit: endLimit,
      );
    }

    if (timing.frequency == null) {
      throw ArgumentError();
    }

    final frequency = timing.frequency!;

    var result = intervals
        .map((x) => EvaluationIntervalModel(x.start, x.end, frequency))
        .toList();

    return result;
  }
}
