import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class CarePlanHelper {
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
    Map<PlanWhenPeriod, int> periods = {};

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
        .fold(
          0,
          (sum, carePlan) => sum + carePlan.timingDayWhen.length,
        );

    periods[PlanWhenPeriod.today] = todayMeasurements;

    if (tomorrowMeasurements > 0) {
      periods[PlanWhenPeriod.tomorrow] = tomorrowMeasurements;
    }

    periods[PlanWhenPeriod.next10] = 10;

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
        measurements = Calendar.getTomorrowMeasurements(
          carePlans: carePlans,
          weekDay: DateTime.now().tomorrowWeekDay(),
        );
        break;
      case PlanWhenPeriod.next10:
        final upcomingMeasurements = Calendar.getNUpcomingMeasurements(
          carePlans: carePlans,
          reqCount: 10,
          measurementResults: measurementResults,
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
    final currentWeekDay = DateTime.now().currentWeekDay();
    final todayCarePlans = carePlans.where(
      (final CarePlan carePlan) => ((carePlan.periodUnit == TimeUnit.day &&
              carePlan.weekDays?.isEmpty == true) ||
          carePlan.weekDays?.contains(currentWeekDay) == true),
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
        );

        if (!MeasurementHelper.wasMeasured(
          plannedMeasurement,
          measurementResults,
        )) {
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
        measurements.add(
          PlannedMeasurement(
            userId: carePlan.userId!,
            whenStart: resultsWhenPeriod == ResultsWhenPeriod.today
                ? timingDayWhen.start.todayDateTime()
                : timingDayWhen.start.yesterdayDateTime(),
            whenEnd: resultsWhenPeriod == ResultsWhenPeriod.today
                ? timingDayWhen.end.todayDateTime()
                : timingDayWhen.end.yesterdayDateTime(),
            timingDayWhen: timingDayWhen,
            carePlan: carePlan,
          ),
        );
      }
    }

    return measurements;
  }

  static List<PlannedMeasurement> getTomorrowMeasurements({
    required List<CarePlan> carePlans,
    required WeekDay weekDay,
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
        measurements.add(
          PlannedMeasurement(
            userId: carePlan.userId!,
            whenStart: timingDayWhen.start.tomorrowDateTime(),
            whenEnd: timingDayWhen.end.tomorrowDateTime(),
            timingDayWhen: timingDayWhen,
            carePlan: carePlan,
          ),
        );
      }
    }

    return measurements;
  }

  static List<PlannedMeasurement> getNUpcomingMeasurements({
    required List<CarePlan> carePlans,
    required int reqCount,
    required List<MeasurementResult> measurementResults,
  }) {
    final List<PlannedMeasurement> upcomingMeasurements = [];

    for (final carePlan in carePlans) {
      final plannedTimingsWhen = carePlan.getTodayRemainingMeasurements();
      for (final plannedTimingWhen in plannedTimingsWhen) {
        final plannedMeasurement = PlannedMeasurement(
          userId: carePlan.userId!,
          whenStart: plannedTimingWhen.start.todayDateTime(),
          whenEnd: plannedTimingWhen.end.todayDateTime(),
          timingDayWhen: plannedTimingWhen,
          carePlan: carePlan,
        );
        if (!MeasurementHelper.wasMeasured(
          plannedMeasurement,
          measurementResults,
        )) {
          upcomingMeasurements.add(plannedMeasurement);
        }
      }
    }

    //start populating tomorrow and other days
    final currentDate = DateTime.now();
    int daysShift = 1;
    while (upcomingMeasurements.length < reqCount) {
      for (final carePlan in carePlans) {
        if (carePlan.periodUnit == TimeUnit.day) {
          if (carePlan.weekDays?.isNotEmpty == true) {
            //add them only in specific days
            final shiftedDate = currentDate.add(Duration(days: daysShift));
            final shiftedWeekDay = WeekDay.values[shiftedDate.weekday - 1];
            if (carePlan.weekDays?.contains(shiftedWeekDay) == true) {
              upcomingMeasurements.addAll(
                getShiftedMeasurements(carePlan, daysShift),
              );
            }
          } else {
            //add daily routes
            upcomingMeasurements.addAll(
              getShiftedMeasurements(carePlan, daysShift),
            );
          }
        }
      }

      daysShift += 1;
    }

    upcomingMeasurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    final upcomingNMeasurements = upcomingMeasurements.take(reqCount).toList();

    return upcomingNMeasurements;
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
  });

  final String userId;
  final DateTime whenStart;
  final DateTime whenEnd;
  final TimingDayWhen timingDayWhen;
  final CarePlan carePlan;
}

enum PlanWhenPeriod {
  today,
  tomorrow,
  next10,
}
