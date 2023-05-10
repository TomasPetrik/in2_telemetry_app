import 'package:collection/collection.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/extensions/list_extensions.dart';

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
      if ((whenPeriod == ResultsWhenPeriod.today &&
              carePlan.hasMeasurementsToday()) ||
          (whenPeriod == ResultsWhenPeriod.yesterday &&
              carePlan.hasMeasurementsYesterday())) {
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
    final List<MeasurementResult> offlineResults,
  ) {
    Map<PlanWhenPeriod, int> periods = {
      PlanWhenPeriod.next10: 10,
    };

    final todayMeasurements =
        getMeasurements(carePlans, PlanWhenPeriod.today, offlineResults);

    final tomorrowMeasurements =
        getMeasurements(carePlans, PlanWhenPeriod.tomorrow, offlineResults);

    periods[PlanWhenPeriod.today] =
        todayMeasurements.fold<int>(0, (prevValue, measurement) {
      if (measurement.isLongPeriod) {
        //skip long period measurements
        return prevValue;
      } else {
        int count = measurement.reqCount;
        if (measurement.currentCount != null) {
          count -= measurement.currentCount!;
        }
        count = count > 0 ? count : 0;
        return prevValue + count;
      }
    });

    periods[PlanWhenPeriod.tomorrow] =
        tomorrowMeasurements.fold<int>(0, (prevValue, measurement) {
      if (measurement.isLongPeriod) {
        //skip long period measurements
        return prevValue;
      } else {
        int count = measurement.reqCount;
        if (measurement.currentCount != null) {
          count -= measurement.currentCount!;
        }
        count = count > 0 ? count : 0;
        return prevValue + count;
      }
    });

    return periods;
  }

  static List<PlannedMeasurement> getMeasurements(
    List<CarePlan> carePlans,
    PlanWhenPeriod whenPeriod,
    List<MeasurementResult> offlineResults,
  ) {
    List<PlannedMeasurement> measurements = [];

    switch (whenPeriod) {
      case PlanWhenPeriod.today:
        measurements = Calendar.getTodayMeasurements(
          carePlans: carePlans,
          offlineResults: offlineResults,
        );
        break;

      case PlanWhenPeriod.tomorrow:
        measurements = Calendar.getMeasurementsOfDay(
          carePlans: carePlans,
          dayDt: DateTime.now().getTomorrowMidnight(),
          offlineResults: offlineResults,
        );
        break;
      case PlanWhenPeriod.next10:
        final upcomingMeasurements = Calendar.getNUpcomingMeasurements(
          carePlans: carePlans,
          reqCount: 10,
          offlineResults: offlineResults,
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
    required List<MeasurementResult> offlineResults,
  }) {
    List<PlannedMeasurement> measurements = [];

    for (final carePlan in carePlans) {
      //add only if the measurement was not in results or in pending results
      final todayRemainingMeasurements = carePlan.getTodayMeasurements2(
        dateTime: DateTime.now(),
        offlineResults: offlineResults,
      );
      measurements.addAll(todayRemainingMeasurements);
    }

    return measurements;
  }

  static List<PlannedMeasurement> getMeasurementsOfDay({
    required List<CarePlan> carePlans,
    required DateTime dayDt,
    required List<MeasurementResult> offlineResults,
    bool all = false,
  }) {
    List<PlannedMeasurement> measurementsOfDay = [];
    for (final carePlan in carePlans) {
      final measurements = carePlan.getMeasurementsOfDay(
        dateTime: dayDt,
        offlineResults: offlineResults,
        all: all,
      );
      measurementsOfDay.addAll(measurements);
    }

    return measurementsOfDay;
  }

  static List<PlannedMeasurement> getMeasurementOfDay({
    required List<CarePlan> carePlans,
    required DateTime dayDt,
    required List<MeasurementResult> offlineResults,
  }) {
    List<PlannedMeasurement> measurementsOfDay = [];
    for (final carePlan in carePlans) {
      final measurements = carePlan.getMeasurementsOfDay(
        dateTime: dayDt,
        offlineResults: offlineResults,
        all: true,
      );
      measurementsOfDay.addAll(measurements);
    }

    return measurementsOfDay;
  }

  static PlannedMeasurement getVeryFirstMeasurement({
    required CarePlan carePlan,
  }) {
    final List<PlannedMeasurement> upcomingMeasurements = [];

    final currentDate = carePlan.scheduledStart;
    int daysShift = 0;
    while (upcomingMeasurements.isEmpty) {
      final measurements = carePlan.getMeasurementsOfDay(
        dateTime: currentDate.add(Duration(days: daysShift)),
      );

      upcomingMeasurements.addAll(measurements);

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
  }) {
    List<PlannedMeasurement> upcomingMeasurements = [];

    final currentDt = DateTime.now();

    //1. add today remaining measurements if exists
    for (final carePlan in carePlans) {
      final todayRemainingMeasurements = carePlan.getTodayMeasurements2(
        dateTime: DateTime.now(),
        offlineResults: offlineResults,
      );
      upcomingMeasurements.addAll(todayRemainingMeasurements);
    }
    upcomingMeasurements.removeWhere((measurement) => measurement.isLongPeriod);

    //2. start populating tomorrow and other days
    upcomingMeasurements = populateOtherDays(
      upcomingMeasurements,
      carePlans,
      reqCount,
      currentDt,
      offlineResults,
    );

    upcomingMeasurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    final upcomingNMeasurements = upcomingMeasurements.take(reqCount).toList();

    //take first total N measurement including frequency

    List<PlannedMeasurement> allMeasurements = upcomingNMeasurements
        .where((measurement) => measurement.isLongPeriod)
        .toList();

    List<PlannedMeasurement> notLongPeriodMeasurements = upcomingNMeasurements
        .whereNot((measurement) => measurement.isLongPeriod)
        .toList();

    List<PlannedMeasurement> nMeasurements = [...allMeasurements];

    int i = 0;
    for (final measurement in notLongPeriodMeasurements) {
      nMeasurements.add(measurement);
      int remCount = measurement.reqCount;
      if (measurement.currentCount != null) {
        remCount -= measurement.currentCount!;
      }
      if (remCount < 0) remCount = 0;

      i += remCount;
      if (i >= reqCount) break;
    }

    return nMeasurements;
  }

  //this method is for setting up notifications
  static List<PlannedMeasurement> getNScheduledMeasurements({
    required List<CarePlan> carePlans,
    required int reqCount,
  }) {
    List<PlannedMeasurement> upcomingMeasurements = [];
    final currentDt = DateTime.now();

    //1. add today remaining measurements for plans which have been started but weren't finished until today midnight
    for (final carePlan in carePlans) {
      final todayUpcomingMeasurements = carePlan.getTodayMeasurements2(
        dateTime: DateTime.now(),
        ignoreOngoing: true,
      );
      upcomingMeasurements.addAll(todayUpcomingMeasurements);
    }

    //2. start populating tomorrow and other days
    upcomingMeasurements = populateOtherDays(
      upcomingMeasurements,
      carePlans,
      reqCount,
      currentDt,
      [],
    );

    upcomingMeasurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    final upcomingNMeasurements = upcomingMeasurements.take(reqCount).toList();

    return upcomingNMeasurements;
  }

  static List<PlannedMeasurement> populateOtherDays(
    List<PlannedMeasurement> upcomingMeasurements,
    List<CarePlan> carePlans,
    int reqCount,
    DateTime currentDt,
    List<MeasurementResult> offlineResults,
  ) {
    int daysShift = 1;
    while (upcomingMeasurements.length < reqCount) {
      final shiftedDate =
          currentDt.getTodayMidnight().add(Duration(days: daysShift));

      //this will prevent deadlock (if we are asking for future measurements but all plans were already ended)
      if (carePlans
              .where(
                (carePlan) =>
                    carePlan.scheduledEnd?.isBefore(shiftedDate) == true,
              )
              .length ==
          carePlans.length) {
        break;
      }

      for (final carePlan in carePlans) {
        //skip plans which haven't been started yet or was already finished
        if (carePlan.scheduledStart.isAfter(shiftedDate) ||
            carePlan.scheduledEnd?.isBefore(shiftedDate) == true) {
          continue;
        }

        final measurements = carePlan.getMeasurementsOfDay(
          dateTime: shiftedDate,
          offlineResults: offlineResults,
        );
        upcomingMeasurements.addAll(measurements);
        //remove duplicates if exist

        upcomingMeasurements = upcomingMeasurements
            .whereWithIndex(
              (element, index) =>
                  upcomingMeasurements.indexWhere(
                    (element2) =>
                        element2.whenStart == element.whenStart &&
                        element2.whenEnd == element.whenEnd &&
                        element2.carePlan.id == element.carePlan.id,
                  ) ==
                  index,
            )
            .toList();
      }

      daysShift += 1;
    }
    return upcomingMeasurements;
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
    this.currentCount,
    this.whenCode,
    this.fulfillmentEvaluationItem,
  });

  final String userId;
  final DateTime whenStart;
  final DateTime whenEnd;
  final TimingDayWhen timingDayWhen;
  final CarePlan carePlan;
  final int reqCount;
  int? currentCount;

  FulfillmentEvaluationItem? fulfillmentEvaluationItem;
  final WhenCode? whenCode;

  bool get isGoingOverDay => !whenStart.isSameDate(whenEnd);

  bool get isLongPeriod =>
      reqCount > 1 && whenStart.difference(whenEnd).abs().inHours > 23;

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
