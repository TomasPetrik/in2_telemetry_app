import 'package:collection/collection.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/candle_data.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';

class ResultsHelper {
  static Map<ResultsWhenPeriod, int?> getPeriodFultillments(
    List<CarePlan> carePlans,
    final List<MeasurementResult> todayAndYesterdayResults,
  ) {
    return {
      ResultsWhenPeriod.yesterday: EvaluationPlanHelper.getProgressFromPlans(
        carePlans: carePlans,
        whenPeriod: ResultsWhenPeriod.yesterday,
        offlineResults: todayAndYesterdayResults,
      ),
      ResultsWhenPeriod.today: EvaluationPlanHelper.getProgressFromPlans(
        carePlans: carePlans,
        whenPeriod: ResultsWhenPeriod.today,
        offlineResults: todayAndYesterdayResults,
      ),
    };
  }

  static List<PlannedMeasurement> getMeasurements(
    final List<CarePlan> allCarePlans,
    final ResultsWhenPeriod whenPeriod,
    final MeasurementType? measurementType,
    final List<MeasurementResult> offlineResults,
  ) {
    List<PlannedMeasurement> measurements = [];

    final carePlans = measurementType != null
        ? allCarePlans
            .where(
              (carePlan) =>
                  carePlan.activity.measurementType == measurementType,
            )
            .toList()
        : allCarePlans;

    switch (whenPeriod) {
      case ResultsWhenPeriod.today:
        measurements = Calendar.getMeasurementsOfDay(
          carePlans: carePlans,
          dayDt: DateTime.now().date,
          offlineResults: offlineResults,
          all: true,
        );
        break;
      case ResultsWhenPeriod.yesterday:
        measurements = Calendar.getMeasurementsOfDay(
          carePlans: carePlans,
          dayDt: DateTime.now().yesterday,
          offlineResults: offlineResults,
          all: true,
        );
        break;
    }

    measurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    return measurements;
  }

  static List<MeasurementResult> getResultsOfDay({
    required final List<PlannedMeasurement> plannedMeasurements,
    required final List<MeasurementResult> serverResults,
    required final List<MeasurementResult> offlineResults,
    required final DateTime startOfDay,
  }) {
    final List<MeasurementResult> allResults = [];

    //sort by isPeriodical because later on we want to add periodicals partials
    //measurements which haven't been included in previous measurements
    plannedMeasurements.sort(
      (a, b) => a.carePlan.isPeriodical != b.carePlan.isPeriodical ? 1 : 0,
    );

    final resultsUntilNow = plannedMeasurements
        .fold<List<MeasurementResult>>([], (prevMeasurements, plMeasurement) {
      List<MeasurementResult> results = [];

      final evaluationItem = plMeasurement.fulfillmentEvaluationItem!;

      if (!plMeasurement.carePlan.isPeriodical) {
        results.add(
          MeasurementResult(
            measurementDateTime:
                evaluationItem.actualMeasurementTimes.isNotEmpty
                    ? evaluationItem.actualMeasurementTimes.first
                    : plMeasurement.whenStart,
            measurementIntervalStart: plMeasurement.whenStart,
            measurementIntervalEnd: plMeasurement.whenEnd,
            evaluationItem: evaluationItem,
            reqCount: plMeasurement.reqCount,
            currentCount: plMeasurement.currentCount!,
            measurementType: plMeasurement.carePlan.activity.measurementType,
            userId: plMeasurement.userId,
            whenCode: plMeasurement.whenCode,
          ),
        );
      } else {
        //we want to show any periodical partial measurements separated
        final actualMeasurementTimes = evaluationItem.actualMeasurementTimes
            .where((measurementTime) => measurementTime.isAfter(startOfDay));
        for (final measurementTime in actualMeasurementTimes) {
          final prevMeasurementTimes = prevMeasurements
              .map((prevMeasurement) => prevMeasurement.measurementDateTime)
              .toList();

          //add this partials only if wasn't included before in other measurements
          if (prevMeasurementTimes.none(
            (prevMeasurementTime) => prevMeasurementTime == measurementTime,
          )) {
            results.add(
              MeasurementResult(
                measurementDateTime: measurementTime,
                measurementIntervalStart: plMeasurement.whenStart,
                measurementIntervalEnd: null,
                //because we want to show them separated
                evaluationItem: evaluationItem,
                reqCount: 1,
                currentCount: 1,
                measurementType:
                    plMeasurement.carePlan.activity.measurementType,
                userId: plMeasurement.userId,
                whenCode: plMeasurement.whenCode,
              ),
            );
          }
        }

        //then show if periodical measurement haven't bee fully completed
        if (!evaluationItem.wasMeasured()) {
          results.add(
            MeasurementResult(
              measurementDateTime: plMeasurement.whenStart,
              measurementIntervalStart: plMeasurement.whenStart,
              measurementIntervalEnd: plMeasurement.whenEnd,
              evaluationItem: evaluationItem,
              reqCount: evaluationItem.requiredMeasurementCount,
              currentCount: evaluationItem.actualMeasurementCount,
              measurementType: plMeasurement.carePlan.activity.measurementType,
              userId: plMeasurement.userId,
              whenCode: plMeasurement.whenCode,
            ),
          );
        }
      }

      return [
        ...prevMeasurements,
        ...results,
      ];
    });

    allResults.addAll(resultsUntilNow);

    //2. Add offline results if they haven't been included in previos measurements
    if (offlineResults.isNotEmpty) {
      final resultsTimes =
          resultsUntilNow.fold<List<DateTime>>([], (prevTimes, result) {
        return [
          ...prevTimes,
          ...result.evaluationItem!.actualMeasurementTimes,
        ];
      });
      //2.1 First remove already included
      offlineResults.removeWhere(
        (offlineResult) => resultsTimes
            .any((dateTime) => dateTime == offlineResult.measurementDateTime),
      );

      //2.2 Then convert them and add to all measurements
      allResults.addAll(
        offlineResults
            .map(
              (offlineResult) => MeasurementResult(
                measurementDateTime: offlineResult.measurementDateTime,
                measurementIntervalEnd: null,
                reqCount: 1,
                currentCount: 1,
                measurementType: offlineResult.measurementType,
                userId: offlineResult.userId,
                whenCode: offlineResult.whenCode,
              ),
            )
            .toList(),
      );
    }

    //3. Add other patient/measurement (s) not included in previous ongoing resolved results;
    // Add measured values to existing results.
    if (serverResults.isNotEmpty) {
      for (final serverResult in serverResults) {
        final matchingResults = resultsUntilNow.where(
          (x) =>
              x.measurementDateTime == serverResult.measurementDateTime &&
              x.measurementType == serverResult.measurementType,
        );

        if (matchingResults.isEmpty) {
          allResults.add(
            MeasurementResult(
              measurementDateTime: serverResult.measurementDateTime,
              measurementIntervalEnd: null,
              reqCount: 1,
              currentCount: 1,
              measurementType: serverResult.measurementType,
              userId: serverResult.userId,
              whenCode: serverResult.whenCode,
              value: serverResult.value,
              composedValue: serverResult.composedValue,
            ),
          );
        } else {
          for (final computedResult in matchingResults) {
            computedResult.value = serverResult.value;
            computedResult.composedValue = serverResult.composedValue;
          }
        }
      }
    }

    allResults.sort((a, b) {
      final dtA = a.measurementDateTime;
      final dtB = b.measurementDateTime;

      return dtB.millisecondsSinceEpoch.compareTo(dtA.millisecondsSinceEpoch);
    });

    return allResults;
  }

  static List<MeasurementResult> getResultsByWhenPeriod({
    required final List<CarePlan> carePlans,
    required final ResultsWhenPeriod whenPeriod,
    required final List<MeasurementResult> allServerResults,
    required final List<MeasurementResult> allOfflineResults,
    MeasurementType? measurementType,
  }) {
    final dtNow = DateTime.now();

    final yesterdayMidnight = dtNow.yesterday;
    final todayMidnight = dtNow.date;
    final tomorrowMidnight = dtNow.tomorrow;

    final offlineResults = allOfflineResults.where((offlineResult) {
      return (measurementType == null ||
                  measurementType == offlineResult.measurementType!) &&
              (whenPeriod == ResultsWhenPeriod.today &&
                  offlineResult.measurementDateTime
                      .isBefore(tomorrowMidnight) &&
                  offlineResult.measurementDateTime.isAfter(todayMidnight)) ||
          (whenPeriod == ResultsWhenPeriod.yesterday &&
              offlineResult.measurementDateTime.isBefore(todayMidnight) &&
              offlineResult.measurementDateTime.isAfter(yesterdayMidnight));
    }).toList();

    final serverResults = allServerResults.where((serverResult) {
      return (measurementType == null ||
              measurementType == serverResult.measurementType!) &&
          ((whenPeriod == ResultsWhenPeriod.today &&
                  serverResult.measurementDateTime.isBefore(tomorrowMidnight) &&
                  serverResult.measurementDateTime.isAfter(todayMidnight)) ||
              (whenPeriod == ResultsWhenPeriod.yesterday &&
                  serverResult.measurementDateTime.isBefore(todayMidnight) &&
                  serverResult.measurementDateTime.isAfter(yesterdayMidnight)));
    }).toList();

    //1. Get results within current time
    final List<PlannedMeasurement> plannedMeasurements = getMeasurements(
      carePlans,
      whenPeriod,
      measurementType,
      offlineResults,
    );

    final pMeasurementsUntilNow = plannedMeasurements.where((measurement) {
      return measurement.whenEnd.isBefore(dtNow) ||
          measurement.fulfillmentEvaluationItem!
              .wasMeasured(); //it's finished measurement
    }).toList();

    final resultsOfDay = getResultsOfDay(
      plannedMeasurements: pMeasurementsUntilNow,
      serverResults: serverResults,
      offlineResults: offlineResults,
      startOfDay: whenPeriod == ResultsWhenPeriod.today
          ? todayMidnight
          : yesterdayMidnight,
    );

    return resultsOfDay;
  }

  static CandleData getCandleByMeasurementResult(
    MeasurementResult measurement,
  ) {
    switch (measurement.measurementType!) {
      case MeasurementType.temperature:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementType.bloodPressure:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.composedValue?.firstValue,
          low: measurement.composedValue?.secondValue,
        );

      case MeasurementType.oxygenSaturation:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementType.heartRate:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementType.respiratoryRate:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementType.shortnessOfBreath:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementType.overallHealth:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementType.steps:
      case MeasurementType.globalPosition:
      case MeasurementType.ews:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: null,
          low: null,
        );
    }
  }

  static CandleData getCandleByMeasurement(
    Measurement measurement,
  ) {
    switch (measurement.measurementType) {
      case MeasurementType.temperature:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.temperature,
          low: 0,
        );
      case MeasurementType.bloodPressure:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.bloodPressure?.systolic?.toDouble(),
          low: measurement.bloodPressure?.diastolic?.toDouble(),
        );

      case MeasurementType.oxygenSaturation:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.oxygenSaturation?.toDouble(),
          low: 0,
        );
      case MeasurementType.heartRate:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.heartRate?.toDouble(),
          low: 0,
        );
      case MeasurementType.respiratoryRate:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.respiratoryRate?.toDouble(),
          low: 0,
        );
      case MeasurementType.shortnessOfBreath:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.shortnessOfBreath?.index.toDouble(),
          low: 0,
        );
      case MeasurementType.overallHealth:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.shortnessOfBreath?.index.toDouble(),
          low: 0,
        );
      case MeasurementType.steps:
      case MeasurementType.globalPosition:
      case MeasurementType.ews:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: null,
          low: null,
        );
    }
  }
}
