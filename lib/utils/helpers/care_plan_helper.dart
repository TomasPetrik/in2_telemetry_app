import 'package:collection/collection.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_version_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/providers/interval_generation/timing_interval_generator.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class CarePlanHelper {
  static DateTime getEarliestDateOfCarePlans(List<CarePlanContract> carePlans) {
    final veryLastDt = carePlans
        .map((carePlan) => carePlan.scheduledStart)
        .sorted((a, b) => b.compareTo(a))
        .last;

    return veryLastDt;
  }

  static List<CarePlanContract> getCarePlansContainingMeasurements({
    required List<CarePlanContract> allCarePlans,
    required ResultsWhenPeriod whenPeriod,
  }) {
    List<CarePlanContract> carePlans = [];
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

  static bool hasMeasurementsToday(CarePlanContract plan) {
    final from = DateTime.now().startOfDay;
    final to = DateTime.now().endOfDay;

    final todayMeasurements = getMeasurements([plan], from, to, []);
    return todayMeasurements.isNotEmpty;
  }

  static bool hasMeasurementsYesterday(CarePlanContract plan) {
    final from =
        DateTime.now().subtract(const Duration(days: 1)).startOfDay;
    final to = DateTime.now().startOfDay;

    final yesterdayMeasurements = getMeasurements([plan], from, to, []);
    return yesterdayMeasurements.isNotEmpty;
  }

  static Set<MeasurementTypeContract> getMeasurementTypes(List<CarePlanContract> carePlans) {
    final measurementTypes = carePlans.map((x) => x.activity.measurementType);
    final result = {...measurementTypes};

    return result;
  }

  static Set<MeasurementTypeContract> getMeasurementTypesByResults(
    List<MeasurementDataContract> results,
  ) {
    final measurementTypes = results.map((x) => x.measurementType);
    final result = {...measurementTypes};

    return result;
  }

  static Map<PlanWhenPeriod, int> getPossibleWhenPeriods(
    final List<CarePlanContract> carePlans,
    final List<MeasurementDataContract> offlineResults,
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
    List<CarePlanContract> carePlans,
    DateTime from,
    DateTime to,
    List<MeasurementDataContract> offlineResults, {
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
    CarePlanVersionContract version,
    CarePlanContract plan,
    DateTime from,
    DateTime to,
    List<MeasurementDataContract> offlineResults, {
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
        userId: plan.targetUserMuid,
        whenStart: interval.start,
        whenEnd: interval.end,
        carePlan: plan,
        reqCount: version.frequency,
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
    List<CarePlanContract> carePlans,
    PlanWhenPeriod whenPeriod,
    List<MeasurementDataContract> offlineResults,
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
    CarePlanContract plan,
    List<MeasurementDataContract> offlineResults,
  ) {
    final from = plan.scheduledStart;
    final to = DateTime.now().endOfDay;

    return getMeasurements([plan], from, to, offlineResults);
  }
}

class Calendar {
  static List<PlannedMeasurement> getMeasurementsOfDay({
    required List<CarePlanContract> carePlans,
    required DateTime dayDt,
    required List<MeasurementDataContract> offlineResults,
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
    required CarePlanContract carePlan,
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
    required List<CarePlanContract> carePlans,
    required int reqCount,
    required List<MeasurementDataContract> offlineResults,
  }) {
    final currentDt = DateTime.now();
    final upcomingMeasurements = generateUpcomingMeasurements(
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
    required List<CarePlanContract> carePlans,
    required int reqCount,
  }) {
    var upcomingMeasurements = generateUpcomingMeasurements(
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

  static List<PlannedMeasurement> generateUpcomingMeasurements(
    List<CarePlanContract> carePlans,
    int reqCount,
    DateTime from,
    List<MeasurementDataContract> offlineResults,
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

  final CarePlanContract carePlan;
  final int reqCount;
  int? currentCount;

  FulfillmentEvaluationItem? fulfillmentEvaluationItem;
  final WhenCodeContract? whenCode;

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
