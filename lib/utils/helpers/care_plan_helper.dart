import 'package:collection/collection.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_version.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/providers/interval_generation/timing_interval_generator.dart';
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
      if ((whenPeriod == ResultsWhenPeriod.today &&
              hasMeasurementsToday(carePlan)) ||
          (whenPeriod == ResultsWhenPeriod.yesterday &&
              hasMeasurementsYesterday(carePlan))) {
        carePlans.add(carePlan);
      }
    }

    return carePlans;
  }

  static bool hasMeasurementsToday(CarePlan plan) {
    final from = DateTime.now().startOfDay;
    final to = DateTime.now().endOfDay;

    final todayMeasurements = getMeasurements([plan], from, to, []);
    return todayMeasurements.isNotEmpty;
  }

  static bool hasMeasurementsYesterday(CarePlan plan) {
    final from =
        DateTime.now().subtract(const Duration(days: 1)).startOfDay;
    final to = DateTime.now().startOfDay;

    final yesterdayMeasurements = getMeasurements([plan], from, to, []);
    return yesterdayMeasurements.isNotEmpty;
  }

  static Set<MeasurementTypeContract> getMeasurementTypes(List<CarePlan> carePlans) {
    final measurementTypes = carePlans.map((x) => x.activity.measurementType);
    final result = {...measurementTypes};

    return result;
  }

  static Set<MeasurementTypeContract> getMeasurementTypesByResults(
    List<MeasurementResult> results,
  ) {
    final measurementTypes = results.map((x) => x.measurementType!);
    final result = {...measurementTypes};

    return result;
  }

  static Map<PlanWhenPeriod, int> getPossibleWhenPeriods(
    final List<CarePlan> carePlans,
    final List<MeasurementResult> offlineResults,
  ) {
    Map<PlanWhenPeriod, int> periods = {
      PlanWhenPeriod.next10: 10,
    };

    final todayMeasurements = getMeasurementsForPeriod(
      carePlans,
      PlanWhenPeriod.today,
      offlineResults,
    );

    final tomorrowMeasurements = getMeasurementsForPeriod(
      carePlans,
      PlanWhenPeriod.tomorrow,
      offlineResults,
    );

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
    DateTime from,
    DateTime to,
    List<MeasurementResult> offlineResults, {
    bool ignoreOngoing = false,
    bool ignoreCompleted = false,
  }) {
    List<PlannedMeasurement> result = [];

    for (final plan in carePlans) {
      final activeVersions = plan.getCpVersions().where(
            (x) => x.isActiveInDates(from, to),
          );

      for (final version in activeVersions) {
        final versionMeasurements = getMeasurementsForVersion(
          version,
          plan,
          from,
          to,
          offlineResults,
          ignoreOngoing: ignoreOngoing,
          ignoreCompleted: ignoreCompleted,
        );

        result.addAll(versionMeasurements);
      }
    }

    return result;
  }

  static List<PlannedMeasurement> getMeasurementsForVersion(
    CarePlanVersion version,
    CarePlan plan,
    DateTime from,
    DateTime to,
    List<MeasurementResult> offlineResults, {
    bool ignoreOngoing = false,
    bool ignoreCompleted = false,
  }) {
    final planStart = [version.activeFrom, version.scheduledStart].max;

    List<DateTime> endLimits = [];
    if (version.activeTo != null) {
      endLimits.add(version.activeTo!);
    }
    if (version.scheduledEnd != null) {
      endLimits.add(version.scheduledEnd!);
    }
    final endLimit = endLimits.minOrNull;

    final intervals = TimingIntervalGenerator.generateIntervalsByRangeAndTiming(
      version.timing,
      from,
      to,
      planStart,
      startLimit: planStart,
      endLimit: endLimit,
    );

    final plannedMeasurements = intervals.map(
      (interval) => PlannedMeasurement(
        userId: plan.userId!,
        whenStart: interval.start,
        whenEnd: interval.end,
        carePlan: plan,
        reqCount: plan.frequency,
        whenCode: interval.whenCode,
      ),
    );

    List<PlannedMeasurement> result = [];

    for (final plannedMeasurement in plannedMeasurements) {
      final fulfillmentEvaluation = MeasurementHelper.getFulfillmentEvaluation(
        plannedMeasurement,
        offlineResults,
      );

      plannedMeasurement.currentCount =
          fulfillmentEvaluation.actualMeasurementCount;
      plannedMeasurement.fulfillmentEvaluationItem = fulfillmentEvaluation;

      if (ignoreOngoing && from.isAfter(plannedMeasurement.whenStart)) {
        continue;
      }

      if (ignoreCompleted &&
          plannedMeasurement.fulfillmentEvaluationItem!.wasMeasured()) {
        continue;
      }

      result.add(plannedMeasurement);
    }

    return result;
  }

  static List<PlannedMeasurement> getMeasurementsForPeriod(
    List<CarePlan> carePlans,
    PlanWhenPeriod whenPeriod,
    List<MeasurementResult> offlineResults,
  ) {
    List<PlannedMeasurement> measurements = [];

    switch (whenPeriod) {
      case PlanWhenPeriod.today:
        final from = DateTime.now();
        final to = from.endOfDay;
        measurements = getMeasurements(
          carePlans,
          from,
          to,
          offlineResults,
          ignoreCompleted: true,
        );
        break;
      case PlanWhenPeriod.tomorrow:
        final from = DateTime.now().tomorrow;
        final to = from.endOfDay;
        measurements = getMeasurements(
          carePlans,
          from,
          to,
          offlineResults,
          ignoreCompleted: true,
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
      (a, b) => a.whenStart.compareTo(b.whenStart),
    );

    return measurements;
  }

  /// Returns all planned measurements up to, and including today
  /// (up to the upcoming midnight).
  static List<PlannedMeasurement> getPlannedMeasurementsUpToToday(
    CarePlan plan,
    List<MeasurementResult> offlineResults,
  ) {
    final from = plan.scheduledStart;
    final to = DateTime.now().endOfDay;

    return getMeasurements([plan], from, to, offlineResults);
  }
}

class Calendar {
  static List<PlannedMeasurement> getMeasurementsOfDay({
    required List<CarePlan> carePlans,
    required DateTime dayDt,
    required List<MeasurementResult> offlineResults,
    bool all = false,
  }) {
    final from = dayDt.startOfDay;
    final to = dayDt.endOfDay;

    return CarePlanHelper.getMeasurements(
      carePlans,
      from,
      to,
      offlineResults,
      ignoreCompleted: !all,
    );
  }

  static PlannedMeasurement getVeryFirstMeasurement({
    required CarePlan carePlan,
  }) {
    final List<PlannedMeasurement> upcomingMeasurements = [];

    final currentDate = carePlan.scheduledStart;
    int daysShift = 0;
    while (upcomingMeasurements.isEmpty) {
      final measurements = getMeasurementsOfDay(
        carePlans: [carePlan],
        dayDt: currentDate.add(Duration(days: daysShift)),
        offlineResults: [],
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
    final currentDt = DateTime.now();
    final upcomingMeasurements = getNUpcomingMeasurementss(
      carePlans,
      reqCount,
      currentDt,
      offlineResults,
      false,
    );

    upcomingMeasurements.sort(
      (a, b) => a.whenStart.compareTo(b.whenStart),
    );

    // Take into account measurement frequency:
    // If a measurement window requires two measurements,
    // count it twice toward the reqCount limit.
    List<PlannedMeasurement> nMeasurements = [];

    int measurementCount = 0;
    for (final measurement in upcomingMeasurements) {
      nMeasurements.add(measurement);
      int remCount = measurement.reqCount;
      if (measurement.currentCount != null) {
        remCount -= measurement.currentCount!;
      }
      if (remCount < 0) remCount = 0;

      measurementCount += remCount;
      if (measurementCount >= reqCount) break;
    }

    return nMeasurements;
  }

  //this method is for setting up notifications
  static List<PlannedMeasurement> getNScheduledMeasurements({
    required List<CarePlan> carePlans,
    required int reqCount,
  }) {
    var upcomingMeasurements = getNUpcomingMeasurementss(
      carePlans,
      reqCount,
      DateTime.now(),
      [],
      true,
    );

    upcomingMeasurements.sort(
      (a, b) => a.whenStart.compareTo(b.whenStart),
    );

    final upcomingNMeasurements = upcomingMeasurements.take(reqCount).toList();

    return upcomingNMeasurements;
  }

  static List<PlannedMeasurement> getNUpcomingMeasurementss(
    List<CarePlan> carePlans,
    int reqCount,
    DateTime from,
    List<MeasurementResult> offlineResults,
    bool ignoreOngoing,
  ) {
    // Using a set to remove duplicates
    // (measurements that span multiple day may be generated twice)
    final Set<PlannedMeasurement> resultSet = {};
    var currentDate = from;

    while (resultSet.length < reqCount &&
        carePlans.any(
          (x) => x.scheduledEnd == null || x.scheduledEnd!.isAfter(currentDate),
        )) {
      final to = currentDate.tomorrow;

      final measurements = CarePlanHelper.getMeasurements(
        carePlans,
        currentDate,
        to,
        offlineResults,
        ignoreOngoing: ignoreOngoing,
        ignoreCompleted: true,
      );

      resultSet.addAll(measurements);

      currentDate = currentDate.tomorrow;
    }
    return resultSet.toList();
  }
}

class PlannedMeasurement {
  PlannedMeasurement({
    required this.userId,
    required this.whenStart,
    required this.whenEnd,
    required this.carePlan,
    required this.reqCount,
    this.currentCount,
    this.whenCode,
    this.fulfillmentEvaluationItem,
  });

  final String userId;
  final DateTime whenStart;
  final DateTime whenEnd;

  final CarePlan carePlan;
  final int reqCount;
  int? currentCount;

  FulfillmentEvaluationItem? fulfillmentEvaluationItem;
  final WhenCode? whenCode;

  bool get isGoingOverDay => !whenStart.isSameDate(whenEnd);

  bool get isLongPeriod =>
      reqCount > 1 && whenStart.difference(whenEnd).abs().inHours > 23;

  @override
  bool operator ==(other) {
    if (other is! PlannedMeasurement) {
      return false;
    }

    return other.whenStart == whenStart &&
        other.whenEnd == whenEnd &&
        other.carePlan.id == carePlan.id;
  }

  @override
  int get hashCode => Object.hash(whenStart, whenEnd, carePlan.id);
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
