import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/candle_data.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

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
      )
    };
  }

  static List<PlannedMeasurement> getMeasurements(
    final List<CarePlan> allCarePlans,
    final ResultsWhenPeriod whenPeriod,
    final MeasurementType? measurementType,
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
        measurements = Calendar.getMeasurements(
          carePlans: carePlans,
          weekDay: DateTime.now().toWeekDay(),
          resultsWhenPeriod: ResultsWhenPeriod.today,
        );
        break;
      case ResultsWhenPeriod.yesterday:
        measurements = Calendar.getMeasurements(
          carePlans: carePlans,
          weekDay: DateTime.now().yesterdaywWeekDay(),
          resultsWhenPeriod: ResultsWhenPeriod.yesterday,
        );
        break;
    }

    measurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch
          .compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    return measurements;
  }

  static List<MeasurementResult> getResults({
    required final List<CarePlan> carePlans,
    required final ResultsWhenPeriod whenPeriod,
    required final List<MeasurementResult> measurementResults,
    required final List<Measurement> offlineResults,
    MeasurementType? measurementType,
  }) {
    final List<MeasurementResult> allResults = [];
    //1. create list of results matching whenPeriod

    List<MeasurementResult> offlineResultsConverted =
        MeasurementHelper.getOffilneResultsConverted(
      offlineResults,
      [whenPeriod],
      measurementType,
    );

    //2. Add not measured results within current time
    final List<PlannedMeasurement> plannedMeasurements =
        getMeasurements(carePlans, whenPeriod, measurementType);

    final dtNow = DateTime.now();
    final plannedMeasurementsWithingCurrentTime =
        plannedMeasurements.where((measurement) {
      return measurement.whenEnd.isBefore(dtNow);
    }).toList();

    final notMeasuredResults = plannedMeasurementsWithingCurrentTime
        .where(
      (measurement) =>
          MeasurementHelper.getEvaluation(
            measurement,
            offlineResultsConverted,
          )?.wasMeasured() ==
          false,
    )
        .map((measurement) {
      final evaluationItem = MeasurementHelper.getEvaluation(
        measurement,
        offlineResultsConverted,
      );
      return MeasurementResult(
        measurementDateTime: measurement.whenStart,
        measurementFinishDateTime: measurement.whenEnd,
        evaluationItem: evaluationItem,
        measurementType: measurement.carePlan.activity.measurementType,
        userId: measurement.userId,
        whenCode: measurement.whenCode,
      );
    });

    allResults.addAll(notMeasuredResults);

    //3. Add ongoing already measured results

    final ongoingResolvedMeasurements =
        plannedMeasurements.where((measurement) {
      return measurement.whenStart.isBefore(dtNow);
    }).toList();
    final ongoingResolvedResults = ongoingResolvedMeasurements
        .where(
      (measurement) =>
          MeasurementHelper.getEvaluation(
            measurement,
            offlineResultsConverted,
          )?.wasMeasured() ==
          true,
    )
        .map((measurement) {
      final evaluationItem = MeasurementHelper.getEvaluation(
        measurement,
        offlineResultsConverted,
      );
      return MeasurementResult(
        measurementDateTime: measurement.whenStart,
        measurementFinishDateTime: measurement.whenEnd,
        evaluationItem: evaluationItem,
        measurementType: measurement.carePlan.activity.measurementType,
        userId: measurement.userId,
        whenCode: measurement.whenCode,
      );
    });

    allResults.addAll(ongoingResolvedResults);

    //4. Add pending results
    //they are covered in ongoing already measured results (offline included)
    //allResults.addAll(offlineResultsConverted);

    //5. Add other patient/measurement (s) not included in previous ongoing resolved results

    final exactTypeAndWhenResults = measurementResults.where((mResult) {
      return ((measurementType == null ||
              (measurementType == mResult.measurementType)) &&
          ((whenPeriod == ResultsWhenPeriod.today &&
                  mResult.measurementDateTime.isToday()) ||
              (whenPeriod == ResultsWhenPeriod.yesterday) &&
                  mResult.measurementDateTime.wasYesterday()));
    });

    final manualMeasurements =
        exactTypeAndWhenResults.where((measurementResult) {
      return !ongoingResolvedResults.any((ongoingResults) {
        return ongoingResults.measurementDateTime
                .isBefore(measurementResult.measurementDateTime) &&
            (ongoingResults.measurementFinishDateTime
                    ?.isAfter(measurementResult.measurementDateTime) ==
                true);
      });
    });
    allResults.addAll(manualMeasurements);

    //6. Add other patient/measurement (s) extra included toward previous ongoing resolved results

    final Set<MeasurementResult> extraMeasurements = {};

    for (final resolvedOngoingResult in ongoingResolvedResults) {
      final measurementsInInterval = exactTypeAndWhenResults.where((pResult) {
        if (resolvedOngoingResult.measurementFinishDateTime
                    ?.isAfter(pResult.measurementDateTime) ==
                true &&
            resolvedOngoingResult.measurementDateTime
                .isBefore(pResult.measurementDateTime)) {
          return true;
        } else {
          return false;
        }
      }).toList();

      //add last N items out of interval
      if (resolvedOngoingResult.evaluationItem != null &&
          measurementsInInterval.length >
              resolvedOngoingResult.evaluationItem!.requiredMeasurementCount) {
        extraMeasurements.addAll(
          measurementsInInterval.toList().reversed.take(
                measurementsInInterval.length -
                    resolvedOngoingResult
                        .evaluationItem!.requiredMeasurementCount,
              ),
        );
      }
    }

    allResults.addAll(extraMeasurements);

    allResults.sort((a, b) {
      final dtA = a.measurementFinishDateTime ?? a.measurementDateTime;
      final dtB = b.measurementFinishDateTime ?? b.measurementDateTime;

      return dtB.millisecondsSinceEpoch.compareTo(dtA.millisecondsSinceEpoch);
    });

    return allResults;
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
    switch (measurement.measurementType!) {
      case MeasurementType.temperature:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.temperature,
          low: 0,
        );
      case MeasurementType.bloodPressure:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.bloodPressure?.systolic?.toDouble(),
          low: measurement.bloodPressure?.diastolic?.toDouble(),
        );

      case MeasurementType.oxygenSaturation:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.oxygenSaturation?.toDouble(),
          low: 0,
        );
      case MeasurementType.heartRate:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.heartRate?.toDouble(),
          low: 0,
        );
      case MeasurementType.respiratoryRate:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: measurement.respiratoryRate?.toDouble(),
          low: 0,
        );
      case MeasurementType.steps:
      case MeasurementType.globalPosition:
      case MeasurementType.ews:
        return CandleData(
          measurementType: measurement.measurementType!,
          timestamp: measurement.measurementDateTime!.millisecondsSinceEpoch,
          high: null,
          low: null,
        );
    }
  }
}

