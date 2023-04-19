import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/author.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaulation_aggregated.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

part 'care_plan.freezed.dart';
part 'care_plan.g.dart';

@unfreezed
class CarePlan with _$CarePlan {
  CarePlan._();

  @HiveType(typeId: 10, adapterName: 'CarePlanAdapter')
  factory CarePlan(
    @HiveField(0) int id,
    @HiveField(1) String? targetUserMuid,
    @HiveField(2) String? finishedByUserMuid,
    @HiveField(3) CarePlanActivity activity,
    @HiveField(4) int versionId,
    @HiveField(5) Author author,
    @JsonKey(fromJson: toLocalDate) @HiveField(6) DateTime scheduledStart,
    @JsonKey(fromJson: toLocalDateNullable)
    @HiveField(7)
        DateTime? scheduledEnd,
    @HiveField(8) int frequency,
    @HiveField(9) int period,
    @HiveField(10) TimeUnit periodUnit,
    @HiveField(11) List<WeekDay>? weekDays,
    @HiveField(12) List<TimingDayWhen> timingDayWhen,
    @HiveField(13) FulfillmentEvaluationAggregated? fullPlanEvaluation,
    @HiveField(14) FulfillmentEvaluation? lastTwoDaysEvaluation,
    @HiveField(15) bool? wasChanged,
    @HiveField(16) String? userId,
    @HiveField(17) bool? wasExpired,
  ) = _CarePlan;

  factory CarePlan.fromJson(Map<String, dynamic> json) =>
      _$CarePlanFromJson(json);

  @override
  String toString() => toJson().toString();

  bool get fihisned => scheduledEnd?.isBefore(DateTime.now()) == true;

  //finished after whole day
  bool isFinisnedByToday() {
    if (scheduledEnd == null) {
      return false;
    }
    final scheduledEndMidnight =
        scheduledEnd!.copyWith(hour: 23, minute: 59, second: 59);

    final isFinisnedByToday =
        scheduledEndMidnight.isBefore(DateTime.now()) == true;
    return isFinisnedByToday;
  }

  bool hasMeasurementAt(DateTime dateTime) {
    final currentWeekDay = dateTime.toWeekDay();
    if ((periodUnit == TimeUnit.day && weekDays?.isEmpty == true) ||
        weekDays?.contains(currentWeekDay) == true) {
      if (timingDayWhen
          .any((when) => when.isInInterval(dateTime.toTimeOfDay()))) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  List<TimingDayWhen> getYesterdayMeasurements() {
    final dtYesterday = DateTime.now().subtract(const Duration(days: 1));
    final currentWeekDay = dtYesterday.toWeekDay();

    if ((periodUnit == TimeUnit.day && weekDays?.isEmpty == true) ||
        weekDays?.contains(currentWeekDay) == true) {
      return timingDayWhen;
    } else {
      return [];
    }
  }

  List<TimingDayWhen> getTodayMeasurements() {
    final now = DateTime.now();
    final currentWeekDay = now.toWeekDay();

    if ((periodUnit == TimeUnit.day && weekDays?.isEmpty == true) ||
        weekDays?.contains(currentWeekDay) == true) {
      return timingDayWhen;
    } else {
      return [];
    }
  }

  List<TimingDayWhen> getTodayRemainingMeasurements({bool? ignoreOngoing}) {
    final now = DateTime.now();
    final currentWeekDay = now.toWeekDay();

    if ((periodUnit == TimeUnit.day && weekDays?.isEmpty == true) ||
        weekDays?.contains(currentWeekDay) == true) {
      return timingDayWhen.where((currentTiming) {
        final measurementTodayStart = currentTiming.start.todayDateTime();
        final measurementTodayEnd = currentTiming.end.todayDateTime();

        return ((now.isBefore(measurementTodayEnd) &&
                now.isAfter(measurementTodayStart) &&
                ignoreOngoing != true) ||
            now.isBefore(measurementTodayStart));
      }).toList();
    } else {
      return [];
    }
  }

  bool hasMeasurementsToday() {
    final now = DateTime.now();
    final currentWeekDay = now.toWeekDay();

    final todayMidnight = now.getTomorrowMidnight();

    final veryFirstMeasurement =
        Calendar.getVeryFirstMeasurement(carePlan: this);
    if (veryFirstMeasurement.whenStart.isAfter(todayMidnight)) {
      return false;
    }

    if ((periodUnit == TimeUnit.day && weekDays?.isEmpty == true) ||
        weekDays?.contains(currentWeekDay) == true) {
      return true;
    } else {
      return false;
    }
  }

  bool hasMeasurementsYesterday() {
    final dtYesterday = DateTime.now().subtract(const Duration(days: 1));
    final currentWeekDay = dtYesterday.toWeekDay();

    final yesterdayMidnight = dtYesterday.getTomorrowMidnight();

    final veryFirstMeasurement =
        Calendar.getVeryFirstMeasurement(carePlan: this);
    if (veryFirstMeasurement.whenStart.isAfter(yesterdayMidnight)) {
      return false;
    }

    if ((periodUnit == TimeUnit.day && weekDays?.isEmpty == true) ||
        weekDays?.contains(currentWeekDay) == true) {
      return true;
    } else {
      return false;
    }
  }
}

@HiveType(typeId: 15)
enum TimeUnit {
  @JsonValue('hour')
  @HiveField(0)
  hour,
  @JsonValue('day')
  @HiveField(1)
  day,
  @JsonValue('week')
  @HiveField(2)
  week,
  @JsonValue('month')
  @HiveField(3)
  month,
  @JsonValue('year')
  @HiveField(4)
  year;
}

@HiveType(typeId: 16)
enum WeekDay {
  @JsonValue('Monday')
  @HiveField(0)
  monday,
  @JsonValue('Tuesday')
  @HiveField(1)
  tuesday,
  @JsonValue('Wednesday')
  @HiveField(2)
  wednesday,
  @JsonValue('Thursday')
  @HiveField(3)
  thursday,
  @JsonValue('Friday')
  @HiveField(4)
  friday,
  @JsonValue('Saturday')
  @HiveField(5)
  saturday,
  @JsonValue('Sunday')
  @HiveField(6)
  sunday;
}
