import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/daily_timing_model.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

// Do not modify without also changing TimingTimeOfDayGenerator.cs in SCSHealthPlatform
class TimingTimeOfDayGenerator {
  /// Gets measurement intervals that occur at [timesOfDay].
  ///
  /// The intervals will start/end [tolerance] minutes sooner/later
  static List<DateTimeRange> getModifiedIntervals(
    List<TimeOfDayTimingModel> timesOfDay,
    List<DateTimeRange> currentIntervals, {
    DateTime? startLimit,
    DateTime? endLimit,
  }) {
    List<DateTimeRange> result = [];

    for (final currentSourceInterval in currentIntervals) {
      for (final dayTime in timesOfDay) {
        // This part differs from SCSHealthPlatform, because tolerance is not available in API
        var startDateTime = currentSourceInterval.start
            .replaceTime(dayTime.measurementWindowStart);
        var endDateTime = currentSourceInterval.start
            .replaceTime(dayTime.measurementWindowEnd);

        if (startDateTime.isAfter(currentSourceInterval.end) ||
            endDateTime.isBefore(currentSourceInterval.start)) {
          continue;
        }

        if (startLimit != null) {
          startDateTime = [startDateTime, startLimit].max;
        }

        if (endLimit != null) {
          endDateTime = [endDateTime, endLimit].min;
        }

        if (!startDateTime.isAtSameMomentAs(endDateTime)) {
          result.add(DateTimeRange(start: startDateTime, end: endDateTime));
        }
      }
    }

    return result;
  }
}
