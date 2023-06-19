import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/author.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_version.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaulation_aggregated.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

part 'care_plan.freezed.dart';
part 'care_plan.g.dart';
part 'care_plan.hive.dart';

@unfreezed
class CarePlan with _$CarePlan {
  CarePlan._();

  @HiveType(typeId: 10, adapterName: 'CarePlanAdapter')
  factory CarePlan({
    @HiveField(0) required int id,
    @HiveField(1) String? targetUserMuid,
    @HiveField(2) String? finishedByUserMuid,
    @HiveField(3) required CarePlanActivity activity,
    @HiveField(4) required int versionId,
    @HiveField(5) required Author author,
    @JsonKey(fromJson: toLocalDate)
    @HiveField(6)
    required DateTime scheduledStart,
    @JsonKey(fromJson: toLocalDateNullable)
    @HiveField(7)
    DateTime? scheduledEnd,
    @HiveField(8) required int frequency,
    @HiveField(9) required int period,
    @HiveField(10) required TimeUnit periodUnit,
    @HiveField(11) required List<WeekDay> weekDays,
    @HiveField(12) required List<TimingDayWhen> timingDayWhen,
    @HiveField(13) FulfillmentEvaluationAggregated? fullPlanEvaluation,
    @HiveField(14) List<FulfillmentEvaluationItem>? serverEvaluationItems,
    @HiveField(15) bool? wasChanged,
    @HiveField(16) String? userId,
    @HiveField(17) bool? wasExpired,
    @HiveField(18) List<CarePlanVersion>? carePlanVersions,
  }) = _CarePlan;

  factory CarePlan.fromJson(Map<String, dynamic> json) =>
      _$CarePlanFromJson(json);

  @override
  String toString() => toJson().toString();

  bool get isPeriodical => timingDayWhen.isEmpty;

  bool get started => scheduledStart.isBefore(DateTime.now());

  bool get fihisned => scheduledEnd?.isBefore(DateTime.now()) == true;

  void addEvaluationItems(List<FulfillmentEvaluationItem> newEvItems) {
    final List<FulfillmentEvaluationItem> newEvItemsList =
        serverEvaluationItems != null ? [...serverEvaluationItems!] : [];

    for (final newEvItem in newEvItems) {
      if (newEvItemsList.none((evItem) => evItem.start == newEvItem.start) ==
          true) {
        newEvItemsList.add(newEvItem);
      }
    }
    serverEvaluationItems = newEvItemsList;
  }

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
    if ((periodUnit == TimeUnit.day && weekDays.isEmpty == true) ||
        weekDays.contains(currentWeekDay) == true) {
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

    if ((periodUnit == TimeUnit.day && weekDays.isEmpty == true) ||
        weekDays.contains(currentWeekDay) == true) {
      return timingDayWhen;
    } else {
      return [];
    }
  }

  Duration getDurationPeriod(final int period, final TimeUnit periodUnit) {
    switch (periodUnit) {
      case TimeUnit.hour:
        return Duration(hours: period);
      case TimeUnit.day:
        return Duration(days: period);
      //week, month, year shoudn't happen as it doesn't make any sense
      case TimeUnit.week:
        return Duration(days: period * 7);
      case TimeUnit.month:
        return Duration(days: period * 30);
      case TimeUnit.year:
        return Duration(days: period * 365);
    }
  }

  List<CarePlanVersion> getCpVersionsOfExactType() {
    final cpVersions = getCpVersions();

    final lastVersion = cpVersions.last;

    final periodicalLastVersion =
        cpVersions.lastWhereOrNull((cpVersion) => cpVersion.isPeriodical);
    final nonPeriodicalLastVersion =
        cpVersions.lastWhereOrNull((cpVersion) => !cpVersion.isPeriodical);

    final List<CarePlanVersion> cpVersions2 = [
      if (periodicalLastVersion != null) periodicalLastVersion,
      if (nonPeriodicalLastVersion != null) nonPeriodicalLastVersion
    ];

    return [lastVersion];
  }

  List<CarePlanVersion> getCpVersions() {
    final List<CarePlanVersion> sortedPlanVersions = [
      if (carePlanVersions != null) ...carePlanVersions!
    ]..sort(
        (a, b) => a.activeFrom.compareTo(b.activeFrom),
      );

    final cpVersions = sortedPlanVersions.isNotEmpty
        ? sortedPlanVersions
        : [
            CarePlanVersion(
              versionId: versionId,
              scheduledStart: scheduledStart,
              frequency: frequency,
              period: period,
              periodUnit: periodUnit,
              weekDays: weekDays,
              timingDayWhen: timingDayWhen,
              activeFrom: scheduledStart,
              activeTo: scheduledEnd,
            )
          ];

    return cpVersions;
  }

  //get all periodical measurements include ongoing
  List<PlannedMeasurement> getPeriodicalMeasurementsOfDay({
    required DateTime dateTime,
    required CarePlanVersion cpVersion,
  }) {
    final List<PlannedMeasurement> periodicalMeasurements = [];
    final startDayDt = dateTime.getStartDay();
    final endDayDt = dateTime.getEndDay();

    //we will start making periods from time when care plan starts
    DateTime measurementStart = cpVersion.activeFrom;
    int currentPeriod = cpVersion.period;
    TimeUnit currentPeriodUnit = cpVersion.periodUnit;

    //we want to reach day when periodical measurement is ongoing

    bool wasAdded = false;
    while (true) {
      final measurementEnd = measurementStart
          .add(getDurationPeriod(currentPeriod, currentPeriodUnit));

      // if current plan version already finished
      if (cpVersion.activeTo?.isBefore(measurementEnd) == true) {
        //try to find next plan version
        final newPlanVersion = getCpVersions().firstWhereOrNull(
          (cpVersion) => cpVersion.activeFrom.isAfter(measurementStart) == true,
        );
        //if exist then set
        if (newPlanVersion != null) {
          cpVersion = newPlanVersion;
          currentPeriod = cpVersion.period;
          currentPeriodUnit = cpVersion.periodUnit;
        } else {
          //otherwise end this loop to prevent deadlock
          break;
        }
      }

      if (
          //take only measurements after scheduledStart and before scheduledEnd
          (measurementStart.isAtSameMomentAs(scheduledStart) ||
                  measurementStart.isAfter(scheduledStart)) &&
              (scheduledEnd == null ||
                  measurementStart.isBefore(scheduledEnd!)) &&

              //measurements started in previous days and finished withing this day,
              ((measurementStart.isBefore(startDayDt) &&
                      measurementEnd.isAfter(startDayDt) &&
                      measurementEnd.isBefore(endDayDt)) ||

                  //measurement started just in this day
                  (measurementStart.isAfter(startDayDt) &&
                      measurementStart.isBefore(endDayDt)) ||

                  //measurement started before this day and still not finished on this day
                  (measurementStart.isBefore(startDayDt) &&
                      measurementEnd.isAfter(endDayDt)))) {
        wasAdded = true;

        periodicalMeasurements.add(
          PlannedMeasurement(
            userId: userId!,
            whenStart: measurementStart,
            whenEnd: measurementEnd,
            timingDayWhen: TimingDayWhen(
              TimingDayWhenType.timeOfDay,
              measurementStart.toTimeOfDay(),
              measurementEnd.toTimeOfDay(),
              null,
              null,
            ),
            carePlan: this,
            reqCount: frequency,
            currentCount: 0, //this will be set later in fulfillment evaluation
          ),
        );
      } else if (wasAdded) {
        break;
      } //prevent to deadlock
      else if (measurementStart.isAfter(dateTime)) {
        break;
      }

      //go on next start of period until this new period is in required day range

      measurementStart = measurementEnd.copyWith();
    }

    return periodicalMeasurements;
  }

  List<PlannedMeasurement> getTodayMeasurements({
    required DateTime dateTime,
    bool ignoreOngoing = false, //for notifications
    List<MeasurementResult>? offlineResults,
  }) {
    assert(dateTime.isToday(), 'This method supports only today');
    final List<PlannedMeasurement> plannedMeasurement = [];

    final currentWeekDay = dateTime.toWeekDay();
    final startOfDay = dateTime.getStartDay();
    final endOfDay = dateTime.getEndDay();

    final activeVersionsOfDay = getCpVersionsOfExactType()
        .where((cpVersion) => cpVersion.isActiveInDates(startOfDay, endOfDay));

    for (final cpVersion in activeVersionsOfDay) {
      final scheduledStart = cpVersion.activeFrom;
      final weekDays = cpVersion.weekDays;
      final isPeriodical = cpVersion.isPeriodical;
      //take only started plans
      if (scheduledStart.isBefore(dateTime) &&
          (weekDays.isEmpty || weekDays.contains(currentWeekDay))) {
        //periodical measurements
        if (isPeriodical) {
          //get all ongoing periodical measurements
          var todayPeriodicalMeasurements = getPeriodicalMeasurementsOfDay(
            dateTime: dateTime,
            cpVersion: cpVersion,
          );

          //first we need only upcomming measurements and ongoing measurements which haven't been finished yet
          // (if we didn't filter them out before)
          todayPeriodicalMeasurements = todayPeriodicalMeasurements
              .where(
                (pMeasurement) =>
                    pMeasurement.whenStart.isAfter(dateTime) ||
                    pMeasurement.whenEnd.isAfter(dateTime),
              )
              .toList();

          //additionaly we may filter out all ongoing measurements even those which haven't been finished yet
          //this is for notifications if is required
          if (ignoreOngoing) {
            todayPeriodicalMeasurements = todayPeriodicalMeasurements
                .where(
                  (pMeasurement) => pMeasurement.whenStart.isAfter(dateTime),
                )
                .toList();
          }

          //in last step we have to set evaluation of periodical measurements and
          //filter out them if they have been fulfilled
          //so we don't want show already completed periodical measurements on dashboard

          for (final pMeasurement in todayPeriodicalMeasurements) {
            final fulfillmentEvaluation =
                MeasurementHelper.getFulfillmentEvaluation(
              pMeasurement,
              offlineResults ?? [],
            );

            pMeasurement.currentCount =
                fulfillmentEvaluation.actualMeasurementCount;
            pMeasurement.fulfillmentEvaluationItem = fulfillmentEvaluation;
          }

          todayPeriodicalMeasurements =
              todayPeriodicalMeasurements.where((pMeasurement) {
            return pMeasurement.fulfillmentEvaluationItem!.wasMeasured() ==
                false;
          }).toList();

          plannedMeasurement.addAll(todayPeriodicalMeasurements);
        } else {
          final regularMeasurements = getTodayRegularMeasurements(
            dateTime: dateTime,
            carePlanVersion: cpVersion,
            offlineResults: offlineResults,
            ignoreOngoing: ignoreOngoing,
          );
          plannedMeasurement.addAll(regularMeasurements);
        }
      }
    }

    return plannedMeasurement;
  }

  List<PlannedMeasurement> getAllTodayPlannedMeasurements({
    required List<MeasurementResult> offlineResults,
  }) {
    final DateTime dtNow = DateTime.now();
    var startOfDay = scheduledStart.getStartDay();

    List<PlannedMeasurement> allPlanMeasurements = [];

    while (true) {
      if ((scheduledEnd != null && startOfDay.isAfter(scheduledEnd!)) ||
          startOfDay.isAfter(dtNow)) {
        break;
      }

      final measurementsOfDay = getMeasurementsOfDay(
        dateTime: startOfDay,
        all: true,
        offlineResults: offlineResults,
      );
      if (measurementsOfDay.isNotEmpty) {
        allPlanMeasurements.addAll(measurementsOfDay);
      }

      startOfDay = startOfDay.add(const Duration(days: 1));
    }

    return allPlanMeasurements;
  }

  //For any day
  List<PlannedMeasurement> getMeasurementsOfDay({
    required DateTime dateTime,
    bool ignoreOngoing = false, //for notifications
    List<MeasurementResult>? offlineResults,
    bool all = false,
  }) {
    List<PlannedMeasurement> plannedMeasurement = [];
    final currentWeekDay = dateTime.toWeekDay();
    final startOfDay = dateTime.getStartDay();
    final endOfDay = dateTime.getEndDay();

    final activeVersionsOfDay = getCpVersions()
        .where((cpVersion) => cpVersion.isActiveInDates(startOfDay, endOfDay));

    for (final cpVersion in activeVersionsOfDay) {
      final weekDays = cpVersion.weekDays;
      final isPeriodical = cpVersion.isPeriodical;

      if ((weekDays.isEmpty || weekDays.contains(currentWeekDay))) {
        //periodical measurements
        if (isPeriodical) {
          //get all ongoing periodical measurements
          var periodicalMeasurements = getPeriodicalMeasurementsOfDay(
            dateTime: dateTime,
            cpVersion: cpVersion,
          );

          //in last step we have to set currentCounts of periodical measurements and
          //filter out them if they have been fulfilled in previous days

          //it can happen when we have long ongoing periodical measurement in future day
          //but we don't want to show it on dashboard as it was fulfilled in previous days

          for (final pMeasurement in periodicalMeasurements) {
            final fulfillmentEvaluationItem =
                MeasurementHelper.getFulfillmentEvaluation(
              pMeasurement,
              offlineResults ?? [],
            );
            pMeasurement.currentCount =
                fulfillmentEvaluationItem.actualMeasurementCount;
            pMeasurement.fulfillmentEvaluationItem = fulfillmentEvaluationItem;
          }

          periodicalMeasurements = periodicalMeasurements
              .where(
                (pMeasurement) =>
                    all ||
                    (pMeasurement.currentCount != null &&
                        pMeasurement.currentCount! < pMeasurement.reqCount ==
                            true),
              )
              .toList();

          plannedMeasurement.addAll(periodicalMeasurements);
        } else {
          final regularMeasurements = getRegularMeasurementsOfDay(
            dateTime: dateTime,
            offlineResults: offlineResults,
            all: all,
          );
          plannedMeasurement.addAll(regularMeasurements);
        }
      }
    }

    return plannedMeasurement;
  }

  List<PlannedMeasurement> getTodayRegularMeasurements({
    required DateTime dateTime,
    required CarePlanVersion carePlanVersion,
    List<MeasurementResult>? offlineResults,
    bool ignoreOngoing = false, //for notifications
  }) {
    assert(dateTime.isToday(), 'This method supports only today');
    List<PlannedMeasurement> plannedMeasurement = [];

    final currentWeekDay = dateTime.toWeekDay();

    final weekDays = carePlanVersion.weekDays;
    final timingDayWhen = carePlanVersion.timingDayWhen;
    final frequency = carePlanVersion.frequency;

    if ((weekDays.isEmpty || weekDays.contains(currentWeekDay))) {
      final nonPeriodicalMeasurements = timingDayWhen.where((currentTiming) {
        final measurementStart = currentTiming.start.todayDateTime();
        final measurementEnd =
            currentTiming.end.todayDateTime().isBefore(measurementStart)
                ? currentTiming.end.todayDateTime().add(const Duration(days: 1))
                : currentTiming.end.todayDateTime();

        return ((!ignoreOngoing &&
                (dateTime.isBefore(measurementEnd) ||
                    dateTime.isAtSameMomentAs(measurementEnd)) &&
                (dateTime.isAfter(measurementStart) ||
                    dateTime.isAtSameMomentAs(measurementStart))) ||
            dateTime.isBefore(measurementStart));
      }).map((timingDayWhen) {
        final measurementStartDt = timingDayWhen.start.todayDateTime();
        final measurementEndDt =
            timingDayWhen.end.todayDateTime().isBefore(measurementStartDt)
                ? timingDayWhen.end.todayDateTime().add(const Duration(days: 1))
                : timingDayWhen.end.todayDateTime();

        final plannedMeasurement = PlannedMeasurement(
          userId: userId!,
          whenStart: measurementStartDt,
          whenEnd: measurementEndDt,
          timingDayWhen: timingDayWhen,
          carePlan: this,
          reqCount: frequency,
          whenCode: timingDayWhen.whenCode,
        );

        final fulfillmentEvaluationItem =
            MeasurementHelper.getFulfillmentEvaluation(
          plannedMeasurement,
          offlineResults ?? [],
        );

        plannedMeasurement.fulfillmentEvaluationItem =
            fulfillmentEvaluationItem;
        plannedMeasurement.currentCount =
            fulfillmentEvaluationItem.actualMeasurementCount;

        return plannedMeasurement;
      })
          //get only not measured if they are ongoing
          .where((plannedMeasurement) {
        return plannedMeasurement.fulfillmentEvaluationItem!.wasMeasured() ==
            false;
      }).toList();

      plannedMeasurement.addAll(nonPeriodicalMeasurements);
    }

    return plannedMeasurement;
  }

  List<PlannedMeasurement> getRegularMeasurementsOfDay({
    required DateTime dateTime,
    List<MeasurementResult>? offlineResults,
    bool all = false,
  }) {
    final startOfDay = dateTime.getStartDay();
    final endOfDay = dateTime.getEndDay();
    final activeVersionsOfDay = getCpVersions()
        .where((cpVersion) => cpVersion.isActiveInDates(startOfDay, endOfDay));

    final List<PlannedMeasurement> plannedMeasurement = [];

    final currentWeekDay = dateTime.toWeekDay();

    for (final cpVersion in activeVersionsOfDay) {
      final weekDays = cpVersion.weekDays;
      final timingDayWhen = cpVersion.timingDayWhen;
      final frequency = cpVersion.frequency;

      if ((weekDays.isEmpty || weekDays.contains(currentWeekDay))) {
        //filter out measurements out of plan version
        final activeTimings = timingDayWhen.where((tdw) {
          final measurementStartDt = tdw.start.ofExactDate(dateTime);
          final measurementEndDt = tdw.end.ofExactDate(dateTime);

          //get only measurements which were started before plan was finished
          bool measurementStartedBeforePlanFinish =
              cpVersion.activeTo == null ||
                  measurementStartDt.isBefore(cpVersion.activeTo!);

          //and those which were started at same moment or after plan was started
          bool measurementStartedAfterPlanStarted =
              measurementStartDt.isAtSameMomentAs(cpVersion.activeFrom) ||
                  measurementEndDt.isAfter(cpVersion.activeFrom);

          return measurementStartedBeforePlanFinish &&
              measurementStartedAfterPlanStarted;
        });

        final regularMeasurements = activeTimings.map((tdw) {
          final measurementStartDt = tdw.start.ofExactDate(dateTime);
          final measurementEndDt =
              tdw.end.ofExactDate(dateTime).isBefore(measurementStartDt)
                  ? tdw.end.ofExactDate(dateTime).add(const Duration(days: 1))
                  : tdw.end.ofExactDate(dateTime);

          final plannedMeasurement = PlannedMeasurement(
            userId: userId!,
            whenStart: measurementStartDt,
            whenEnd: measurementEndDt,
            timingDayWhen: tdw,
            carePlan: this,
            reqCount: frequency,
            whenCode: tdw.whenCode,
          );

          final fulfillmentEvaluationItem =
              MeasurementHelper.getFulfillmentEvaluation(
            plannedMeasurement,
            offlineResults ?? [],
          );
          plannedMeasurement.fulfillmentEvaluationItem =
              fulfillmentEvaluationItem;
          plannedMeasurement.currentCount =
              fulfillmentEvaluationItem.actualMeasurementCount;

          return plannedMeasurement;
        })

            //filter out already measured
            //it may happen only for measurements which were started day before and finish in next day
            //but they were completed in that day before
            .where((pMeasurement) {
          return (all ||
              pMeasurement.fulfillmentEvaluationItem!.wasMeasured() == false);
        }).toList();

        plannedMeasurement.addAll(regularMeasurements);
      }
    }

    return plannedMeasurement;
  }

  bool hasMeasurementsToday() {
    final todaysMeasurements =
        getMeasurementsOfDay(dateTime: DateTime.now(), all: true);

    return todaysMeasurements.isNotEmpty;
  }

  bool hasMeasurementsYesterday() {
    final yesterdayDt = DateTime.now().subtract(const Duration(days: 1));

    final yesterdayMeasurements =
        getMeasurementsOfDay(dateTime: yesterdayDt, all: true);

    return yesterdayMeasurements.isNotEmpty;
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
