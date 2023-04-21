import 'package:collection/collection.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class CarePlanHelper {
  static DateTime getEarliestDateOfCarePlans(List<CarePlan> carePlans) {
    final veryLastDt = carePlans
        .map((carePlan) => carePlan.scheduledStart)
        .sorted((a, b) => b.compareTo(a))
        .last;

    return veryLastDt;
  }

  static List<CarePlan> getCarePlansContainingMeasurements({
    required List<CarePlan> allCarePlans,
    required ResultsWhenPeriod whenPeriod,
  }) {
    List<CarePlan> carePlans = [];
    for (final carePlan in allCarePlans) {
      if (carePlan.isFinisnedByToday() == false &&
          ((whenPeriod == ResultsWhenPeriod.today &&
                  carePlan.hasMeasurementsToday()) ||
              (whenPeriod == ResultsWhenPeriod.yesterday &&
                  carePlan.hasMeasurementsYesterday()))) {
        carePlans.add(carePlan);
      }
    }

    return carePlans;
  }

  static Set<MeasurementType> getMeasurementTypes(List<CarePlan> carePlans) {
    final measurementTypes = <MeasurementType>{};
    carePlans
        .where(
          (carePlan) => measurementTypes.add(carePlan.activity.measurementType),
        )
        .toList();

    return measurementTypes;
  }

  static Map<PlanWhenPeriod, int> getPossibleWhenPeriods(
    final List<CarePlan> carePlans,
    final List<MeasurementResult> todayResults,
  ) {
    Map<PlanWhenPeriod, int> periods = {
      PlanWhenPeriod.next10: 10,
    };

    final tomorrowWeekDay = DateTime.now().tomorrowWeekDay();

    final todayMeasurements =
        getMeasurements(carePlans, PlanWhenPeriod.today, todayResults).length;

    final tomorrowMeasurements = carePlans
        .where(
          (final CarePlan carePlan) =>
              (carePlan.periodUnit == TimeUnit.day &&
                  carePlan.weekDays?.isEmpty == true) ||
              carePlan.weekDays?.contains(tomorrowWeekDay) == true,
        )
        .fold<int>(
          0,
          (sum, carePlan) => sum + carePlan.timingDayWhen.length,
        );

    periods[PlanWhenPeriod.today] = todayMeasurements;

    if (tomorrowMeasurements > 0) {
      periods[PlanWhenPeriod.tomorrow] = tomorrowMeasurements;
    }

    return periods;
  }

  static List<PlannedMeasurement> getMeasurements(
    List<CarePlan> carePlans,
    PlanWhenPeriod whenPeriod,
    List<MeasurementResult> measurementResults,
  ) {
    List<PlannedMeasurement> measurements = [];

    switch (whenPeriod) {
      case PlanWhenPeriod.today:
        measurements = Calendar.getTodayMeasurements(
          carePlans: carePlans,
          measurementResults: measurementResults,
        );
        break;
      case PlanWhenPeriod.tomorrow:
        measurements = Calendar.getMeasurementOfDay(
          carePlans: carePlans,
          dayDt: DateTime.now().getTomorrowMidnight(),
        );
        break;
      case PlanWhenPeriod.next10:
        final upcomingMeasurements = Calendar.getNUpcomingMeasurements(
          carePlans: carePlans,
          reqCount: 10,
          offlineResults: measurementResults,
        );
        measurements.addAll(upcomingMeasurements);
        break;
    }

    measurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    return measurements;
  }
}

class Calendar {
  static List<PlannedMeasurement> getTodayMeasurements({
    required List<CarePlan> carePlans,
    required List<MeasurementResult> measurementResults,
  }) {
    List<PlannedMeasurement> measurements = [];
    final dtNow = DateTime.now();
    final currentWeekDay = dtNow.toWeekDay();
    final todayCarePlans = carePlans.where(
      (final CarePlan carePlan) => (carePlan.scheduledStart.isBefore(dtNow) &&
          ((carePlan.periodUnit == TimeUnit.day &&
                  carePlan.weekDays?.isEmpty == true) ||
              carePlan.weekDays?.contains(currentWeekDay) == true)),
    );

    for (final carePlan in todayCarePlans) {
      final timingDaysWhen = carePlan.getTodayRemainingMeasurements();
      for (final timingDayWhen in timingDaysWhen) {
        //add only if the measurement was not in results or in pending results
        //MeasurementHelper.getResults(measurementResults, whenPeriod, measurementType)

        final plannedMeasurement = PlannedMeasurement(
          userId: carePlan.userId!,
          whenStart: timingDayWhen.start.todayDateTime(),
          whenEnd: timingDayWhen.end.todayDateTime(),
          timingDayWhen: timingDayWhen,
          carePlan: carePlan,
          reqCount: carePlan.frequency,
        );

        if (MeasurementHelper.getEvaluation(
              plannedMeasurement,
              measurementResults,
            )?.wasMeasured() ==
            false) {
          measurements.add(plannedMeasurement);
        }
      }
    }

    return measurements;
  }

  static List<PlannedMeasurement> getMeasurements({
    required List<CarePlan> carePlans,
    required WeekDay weekDay,
    required ResultsWhenPeriod resultsWhenPeriod,
  }) {
    List<PlannedMeasurement> measurements = [];
    final dailyCarePlans = carePlans.where(
      (final CarePlan carePlan) =>
          (carePlan.periodUnit == TimeUnit.day &&
              carePlan.weekDays?.isEmpty == true) ||
          carePlan.weekDays?.contains(weekDay) == true,
    );
    for (final carePlan in dailyCarePlans) {
      for (final timingDayWhen in carePlan.timingDayWhen) {
        final measurementStartTime =
            resultsWhenPeriod == ResultsWhenPeriod.today
                ? timingDayWhen.start.todayDateTime()
                : timingDayWhen.start.yesterdayDateTime();

        if (measurementStartTime.isAfter(carePlan.scheduledStart)) {
          measurements.add(
            PlannedMeasurement(
              userId: carePlan.userId!,
              whenStart: measurementStartTime,
              whenEnd: resultsWhenPeriod == ResultsWhenPeriod.today
                  ? timingDayWhen.end.todayDateTime()
                  : timingDayWhen.end.yesterdayDateTime(),
              timingDayWhen: timingDayWhen,
              carePlan: carePlan,
              reqCount: carePlan.frequency,
              whenCode: timingDayWhen.whenCode,
            ),
          );
        }
      }
    }

    return measurements;
  }

  static List<PlannedMeasurement> getMeasurementOfDay({
    required List<CarePlan> carePlans,
    required DateTime dayDt,
  }) {
    final weekDay = dayDt.toWeekDay();

    List<PlannedMeasurement> measurements = [];
    final dailyCarePlans = carePlans.where(
      (final CarePlan carePlan) =>
          (carePlan.periodUnit == TimeUnit.day &&
              carePlan.weekDays?.isEmpty == true) ||
          carePlan.weekDays?.contains(weekDay) == true,
    );
    for (final carePlan in dailyCarePlans) {
      for (final timingDayWhen in carePlan.timingDayWhen) {
        final whenEnd = timingDayWhen.end.ofExactDate(dayDt);
        final whenStart = timingDayWhen.start.ofExactDate(dayDt);
        if (carePlan.scheduledStart.isAfter(whenEnd)) continue;
        if (carePlan.scheduledEnd?.isBefore(whenStart) == true) continue;
        measurements.add(
          PlannedMeasurement(
            userId: carePlan.userId!,
            whenStart: timingDayWhen.start.ofExactDate(dayDt),
            whenEnd: timingDayWhen.end.ofExactDate(dayDt),
            timingDayWhen: timingDayWhen,
            carePlan: carePlan,
            reqCount: carePlan.frequency,
            whenCode: timingDayWhen.whenCode,
          ),
        );
      }
    }

    return measurements;
  }

  static PlannedMeasurement getVeryFirstMeasurement({
    required CarePlan carePlan,
  }) {
    final List<PlannedMeasurement> upcomingMeasurements = [];

    //start populating tomorrow and other days
    final currentDate = carePlan.scheduledStart;
    int daysShift = 0;
    while (upcomingMeasurements.isEmpty) {
      if (carePlan.periodUnit == TimeUnit.day) {
        if (carePlan.weekDays?.isNotEmpty == true) {
          //add them only in specific days
          final shiftedDate = currentDate.add(Duration(days: daysShift));
          final shiftedWeekDay = WeekDay.values[shiftedDate.weekday - 1];
          if (carePlan.weekDays?.contains(shiftedWeekDay) == true) {
            upcomingMeasurements.addAll(
              getMeasurementsAtDate(carePlan, currentDate, daysShift),
            );
          }
        } else {
          //add daily routes
          upcomingMeasurements.addAll(
            getMeasurementsAtDate(carePlan, currentDate, daysShift),
          );
        }
      }

      daysShift += 1;
    }

    upcomingMeasurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    final veryFirstMeasurement = upcomingMeasurements.first;

    return veryFirstMeasurement;
  }

  static List<PlannedMeasurement> getNUpcomingMeasurements({
    required List<CarePlan> carePlans,
    required int reqCount,
    required List<MeasurementResult> offlineResults,
    bool? ignoreOngoing,
  }) {
    final List<PlannedMeasurement> upcomingMeasurements = [];

    final currentDt = DateTime.now();

    //1. add today remaining measurements if exists
    for (final carePlan in carePlans) {
      if (carePlan.scheduledStart.isAfter(currentDt)) continue;
      final plannedTimingsWhen =
          carePlan.getTodayRemainingMeasurements(ignoreOngoing: ignoreOngoing);
      for (final plannedTimingWhen in plannedTimingsWhen) {
        final plannedMeasurement = PlannedMeasurement(
          userId: carePlan.userId!,
          whenStart: plannedTimingWhen.start.todayDateTime(),
          whenEnd: plannedTimingWhen.end.todayDateTime(),
          timingDayWhen: plannedTimingWhen,
          carePlan: carePlan,
          reqCount: carePlan.frequency,
        );

        //include only not measured measurements
        if (ignoreOngoing == true ||
            MeasurementHelper.getEvaluation(
                  plannedMeasurement,
                  offlineResults,
                )?.wasMeasured() ==
                false) {
          upcomingMeasurements.add(plannedMeasurement);
        }
      }
    }

    //2. start populating tomorrow and other days
    popupateOtherDays(
      upcomingMeasurements,
      carePlans,
      reqCount,
      currentDt,
    );

    upcomingMeasurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    final upcomingNMeasurements = upcomingMeasurements.take(reqCount).toList();

    return upcomingNMeasurements;
  }

  static List<PlannedMeasurement> getNNextMeasurements({
    required List<CarePlan> carePlans,
    required int reqCount,
  }) {
    final List<PlannedMeasurement> upcomingMeasurements = [];
    final currentDt = DateTime.now();

    //1. add today remaining measurements if exists
    for (final carePlan in carePlans) {
      if (carePlan.scheduledStart.isAfter(currentDt)) continue;
      final plannedTimingsWhen =
          carePlan.getTodayRemainingMeasurements(ignoreOngoing: true);
      for (final plannedTimingWhen in plannedTimingsWhen) {
        final plannedMeasurement = PlannedMeasurement(
          userId: carePlan.userId!,
          whenStart: plannedTimingWhen.start.todayDateTime(),
          whenEnd: plannedTimingWhen.end.todayDateTime(),
          timingDayWhen: plannedTimingWhen,
          carePlan: carePlan,
          reqCount: carePlan.frequency,
          whenCode: plannedTimingWhen.whenCode,
        );

        upcomingMeasurements.add(plannedMeasurement);
      }
    }

    //2. start populating tomorrow and other days
    popupateOtherDays(
      upcomingMeasurements,
      carePlans,
      reqCount,
      currentDt,
    );

    upcomingMeasurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    final upcomingNMeasurements = upcomingMeasurements.take(reqCount).toList();

    return upcomingNMeasurements;
  }

  static void popupateOtherDays(
    List<PlannedMeasurement> upcomingMeasurements,
    List<CarePlan> carePlans,
    int reqCount,
    DateTime currentDt,
  ) {
    int daysShift = 1;
    while (upcomingMeasurements.length < reqCount) {
      for (final carePlan in carePlans) {
        if (carePlan.periodUnit == TimeUnit.day) {
          final shiftedDate = currentDt.add(Duration(days: daysShift));
          if (Calendar.getVeryFirstMeasurement(carePlan: carePlan)
              .whenStart
              .isAfter(shiftedDate)) {
            continue;
          }

          if (carePlan.weekDays?.isNotEmpty == true) {
            //add them only in specific days

            final shiftedWeekDay = WeekDay.values[shiftedDate.weekday - 1];
            if (carePlan.weekDays?.contains(shiftedWeekDay) == true) {
              upcomingMeasurements.addAll(
                getShiftedMeasurements(carePlan, daysShift),
              );
            }
          } else {
            //add daily routines

            upcomingMeasurements.addAll(
              getShiftedMeasurements(carePlan, daysShift),
            );
          }
        }
      }

      daysShift += 1;
    }
  }

  static List<PlannedMeasurement> getShiftedMeasurements(
    CarePlan carePlan,
    int daysShift,
  ) {
    return carePlan.timingDayWhen
        .map(
          (timingDayWhen) => PlannedMeasurement(
            userId: carePlan.userId!,
            whenStart: timingDayWhen.start
                .todayDateTime()
                .add(Duration(days: daysShift)),
            whenEnd: timingDayWhen.end
                .todayDateTime()
                .add(Duration(days: daysShift)),
            timingDayWhen: timingDayWhen,
            carePlan: carePlan,
            reqCount: carePlan.frequency,
          ),
        )
        .toList();
  }

  static List<PlannedMeasurement> getMeasurementsAtDate(
    CarePlan carePlan,
    DateTime dateTime,
    int daysShift,
  ) {
    return carePlan.timingDayWhen
        .map(
          (timingDayWhen) => PlannedMeasurement(
            userId: carePlan.userId!,
            whenStart: timingDayWhen.start
                .ofExactDate(dateTime)
                .add(Duration(days: daysShift)),
            whenEnd: timingDayWhen.end
                .ofExactDate(dateTime)
                .add(Duration(days: daysShift)),
            timingDayWhen: timingDayWhen,
            carePlan: carePlan,
            reqCount: carePlan.frequency,
          ),
        )
        .toList();
  }
}

class PlannedMeasurement {
  PlannedMeasurement({
    required this.userId,
    required this.whenStart,
    required this.whenEnd,
    required this.timingDayWhen,
    required this.carePlan,
    required this.reqCount,
    this.whenCode,
  });

  final String userId;
  final DateTime whenStart;
  final DateTime whenEnd;
  final TimingDayWhen timingDayWhen;
  final CarePlan carePlan;
  final int reqCount;
  WhenCode? whenCode;

  bool hasMeasurementAt(DateTime dateTime) {
    if (dateTime.isBefore(whenEnd) && dateTime.isAfter(whenStart)) {
      return true;
    } else {
      return false;
    }
  }
}

class HistoricMeasurement {
  HistoricMeasurement({
    required this.userId,
    required this.whenStart,
    required this.whenEnd,
    required this.measuredAt,
    required this.carePlan,
    required this.reqCount,
    required this.actualCount,
    required this.wasMeasured,
    required this.whenCode,
  });

  final String userId;
  final DateTime whenStart;
  final DateTime whenEnd;
  DateTime? measuredAt;
  final CarePlan carePlan;
  final int reqCount;
  final int actualCount;
  final bool wasMeasured;
  WhenCode? whenCode;

  bool hasMeasurementAt(DateTime dateTime) {
    if (dateTime.isBefore(whenEnd) && dateTime.isAfter(whenStart)) {
      return true;
    } else {
      return false;
    }
  }
}

enum PlanWhenPeriod {
  today,
  tomorrow,
  next10,
}

enum WhenPeriod {
  yesterday,
  today,
  tomorrow,
}
