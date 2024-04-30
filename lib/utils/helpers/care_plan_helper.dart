import 'package:collection/collection.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/time_of_day_timing_model.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/timing_model.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/enums/timing_day_when_type.dart';
import 'package:scalesoft_app/data/entities/enums/when_code.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_version.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';
import 'package:scalesoft_app/providers/interval_generation/timing_interval_generator.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class CarePlanHelper {
  static DateTime getEarliestDateOfCarePlans(Iterable<CarePlan> carePlans) {
    final minDate = carePlans.map((plan) => plan.versions.map((version) => version.scheduledStart).min).min;

    return minDate;
  }

  static List<CarePlan> getCarePlansContainingMeasurements({
    required List<CarePlan> allCarePlans,
    required ResultsWhenPeriod whenPeriod,
  }) {
    List<CarePlan> carePlans = [];
    for (final carePlan in allCarePlans) {
      if ((whenPeriod == ResultsWhenPeriod.today && hasMeasurementsToday(carePlan)) ||
          (whenPeriod == ResultsWhenPeriod.yesterday && hasMeasurementsYesterday(carePlan))) {
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
    final from = DateTime.now().subtract(const Duration(days: 1)).startOfDay;
    final to = DateTime.now().startOfDay;

    final yesterdayMeasurements = getMeasurements([plan], from, to, []);
    return yesterdayMeasurements.isNotEmpty;
  }

  static Set<MeasurementType> getMeasurementTypes(List<CarePlan> carePlans) {
    final measurementTypes = carePlans.map((x) => x.activity.measurementType);
    final result = {...measurementTypes};

    return result;
  }

  static Map<PlanWhenPeriod, int> getPossibleWhenPeriods(
    final List<CarePlan> carePlans,
    final List<Measurement> offlineResults,
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

    periods[PlanWhenPeriod.today] = todayMeasurements.fold<int>(0, (prevValue, measurement) {
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

    periods[PlanWhenPeriod.tomorrow] = tomorrowMeasurements.fold<int>(0, (prevValue, measurement) {
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
    List<Measurement> offlineResults, {
    bool ignoreOngoing = false,
    bool ignoreCompleted = false,
  }) {
    List<PlannedMeasurement> result = [];

    for (final plan in carePlans) {
      final activeVersions = plan.versions.where(
        (x) => x.activeFrom.isBefore(to) && (x.activeTo?.isAfter(from) ?? true),
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

  static TimingModel _getTimingModel(CarePlanVersion version) {
    final when = version.timingDayWhen.where((x) => x.type == TimingDayWhenType.when && x.whenCode != null).toList();

    final timesOfDay = version.timingDayWhen
        .where((x) => x.type == TimingDayWhenType.timeOfDay && x.timeOfDay != null)
        .map(
          (x) => TimeOfDayTimingModel(x.start.toDuration(), x.end.toDuration()),
        )
        .toList();

    return TimingModel(
      version.frequency,
      version.period,
      version.periodUnit,
      version.weekDays,
      timesOfDay,
      when,
    );
  }

  static List<PlannedMeasurement> getMeasurementsForVersion(
    CarePlanVersion version,
    CarePlan plan,
    DateTime from,
    DateTime to,
    List<Measurement> offlineResults, {
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

    final timing = _getTimingModel(version);

    final intervals = TimingIntervalGenerator.generateIntervalsByRangeAndTiming(
      timing,
      from,
      to,
      planStart,
      startLimit: planStart,
      endLimit: endLimit,
    );

    final plannedMeasurements = intervals.map(
      (interval) => PlannedMeasurement(
        userId: plan.targetUserId,
        whenStart: interval.start,
        whenEnd: interval.end,
        measurementType: plan.activity.measurementType,
        reqCount: version.frequency,
        whenCode: interval.whenCode,
      ),
    );

    List<PlannedMeasurement> result = [];

    for (final plannedMeasurement in plannedMeasurements) {
      final fulfillmentEvaluation = MeasurementHelper.getFulfillmentEvaluation(
        plannedMeasurement,
        offlineResults,
        plan.evaluationItems,
      );

      plannedMeasurement.currentCount = fulfillmentEvaluation.actualMeasurementCount;
      plannedMeasurement.fulfillmentEvaluationItem = fulfillmentEvaluation;

      if (ignoreOngoing && from.isAfter(plannedMeasurement.whenStart)) {
        continue;
      }

      if (ignoreCompleted && wasMeasured(fulfillmentEvaluation)) {
        continue;
      }

      result.add(plannedMeasurement);
    }

    return result;
  }

  static List<PlannedMeasurement> getMeasurementsForPeriod(
    List<CarePlan> carePlans,
    PlanWhenPeriod whenPeriod,
    List<Measurement> offlineResults,
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
    List<Measurement> offlineResults,
  ) {
    final from = plan.versions.map((x) => x.scheduledStart).min;
    final to = DateTime.now().endOfDay;

    return getMeasurements([plan], from, to, offlineResults);
  }

  static bool wasMeasured(FulfillmentEvaluationItem? item) {
    if (item == null) {
      return false;
    }
    return item.actualMeasurementCount >= item.requiredMeasurementCount;
  }

  /// Checks whether the latest version of the given [plan] is periodical (has no times of day)
  static bool isPeriodical(CarePlan plan) {
    final currentVersion = plan.versions.sortedBy((x) => x.activeFrom).last;
    return currentVersion.timingDayWhen.isEmpty;
  }
}

class Calendar {
  static List<PlannedMeasurement> getPlannedMeasurementsOfDay({
    required List<CarePlan> carePlans,
    required DateTime dayDt,
    required List<Measurement> offlineResults,
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

    final currentDate = carePlan.versions.map((x) => x.scheduledStart).min;
    int daysShift = 0;
    while (upcomingMeasurements.isEmpty) {
      final measurements = getPlannedMeasurementsOfDay(
        carePlans: [carePlan],
        dayDt: currentDate.add(Duration(days: daysShift)),
        offlineResults: [],
      );

      upcomingMeasurements.addAll(measurements);

      daysShift += 1;
    }

    upcomingMeasurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch.compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    final veryFirstMeasurement = upcomingMeasurements.first;

    return veryFirstMeasurement;
  }

  static List<PlannedMeasurement> getNUpcomingMeasurements({
    required List<CarePlan> carePlans,
    required int reqCount,
    required List<Measurement> offlineResults,
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
    required List<CarePlan> carePlans,
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
    List<CarePlan> carePlans,
    int reqCount,
    DateTime from,
    List<Measurement> offlineResults,
    bool ignoreOngoing,
  ) {
    // Using a set to remove duplicates
    // (measurements that span multiple day may be generated twice)
    final Set<PlannedMeasurement> resultSet = {};
    var currentDate = from;

    while (resultSet.length < reqCount &&
        carePlans.any(
          (x) =>
              x.versions.any((version) => version.scheduledEnd == null || version.scheduledEnd!.isAfter(currentDate)),
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
    required this.measurementType,
    required this.reqCount,
    this.currentCount,
    this.whenCode,
    this.fulfillmentEvaluationItem,
  });

  final int userId;
  final DateTime whenStart;
  final DateTime whenEnd;

  final int reqCount;
  int? currentCount;

  FulfillmentEvaluationItem? fulfillmentEvaluationItem;
  final WhenCode? whenCode;
  final MeasurementType measurementType;

  bool get isGoingOverDay => !whenStart.isSameDate(whenEnd);

  bool get isLongPeriod => reqCount > 1 && whenStart.difference(whenEnd).abs().inHours > 23;

  @override
  bool operator ==(other) {
    if (other is! PlannedMeasurement) {
      return false;
    }

    return other.whenStart == whenStart && other.whenEnd == whenEnd && other.measurementType == measurementType && other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(whenStart, whenEnd, measurementType, userId);
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
