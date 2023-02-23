import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_double_value.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class MeasurementHelper {
  static FulfillmentEvaluationItem? getEvaluation(
    PlannedMeasurement plannedMeasurement,
    List<MeasurementResult> offlineResults,
  ) {
    //check if was measured
    final evaluationItems =
        plannedMeasurement.carePlan.lastTwoDaysEvaluation?.items;
    if (evaluationItems?.isNotEmpty == true) {
      for (final measurementEvalutionItem in evaluationItems!) {
        if (plannedMeasurement.whenStart
                .isAtSameMomentAs(measurementEvalutionItem.start) &&
            (measurementEvalutionItem.end
                    .isBefore(plannedMeasurement.whenEnd) ||
                plannedMeasurement.whenEnd
                    .isAtSameMomentAs(measurementEvalutionItem.end))) {
          return measurementEvalutionItem;
        }
      }
    }

    //check if was measured offline
    final measuredTimesSet = offlineResults.where(
      (mResult) {
        return mResult.measurementType ==
                plannedMeasurement.carePlan.activity.measurementType &&
            mResult.userId == plannedMeasurement.userId;
      },
    ).map((mResult) => mResult.measurementDateTime);

    int matchedResultCount = 0;
    List<DateTime> actualMeasurementTimes = [];
    for (final measuredTime in measuredTimesSet) {
      if (plannedMeasurement.whenStart.isBefore(measuredTime) &&
          plannedMeasurement.whenEnd.isAfter(measuredTime)) {
        matchedResultCount += 1;

        actualMeasurementTimes.add(measuredTime);
      }
    }

    return FulfillmentEvaluationItem(
      plannedMeasurement.whenStart,
      plannedMeasurement.whenEnd,
      plannedMeasurement.reqCount,
      matchedResultCount,
      actualMeasurementTimes,
    );
  }

  static List<MeasurementResult> getResults(
    List<MeasurementResult> measurementResults,
    List<Measurement> pendingResults,
    List<ResultsWhenPeriod> whenPeriods,
    MeasurementType? measurementType,
  ) {
    List<MeasurementResult> results = measurementResults.where((mResult) {
      return ((measurementType == null ||
              (measurementType == mResult.measurementType)) &&
          ((whenPeriods.contains(ResultsWhenPeriod.today) &&
                  mResult.measurementDateTime.isToday()) ||
              (whenPeriods.contains(ResultsWhenPeriod.yesterday) &&
                  mResult.measurementDateTime.wasYesterday())));
    }).toList();

    //include not synced results

    final filteredPendingResults = getOffilneResultsConverted(
      pendingResults,
      whenPeriods,
      measurementType,
    );

    results.addAll(filteredPendingResults);

    return results;
  }

  static List<MeasurementResult> getOffilneResultsConverted(
    List<Measurement> pendingResults,
    List<ResultsWhenPeriod> whenPeriods,
    MeasurementType? measurementType,
  ) {
    //offline (not synced results)
    final measurementResults = pendingResults
        .where((pResult) {
          return ((measurementType == null ||
                  (measurementType == pResult.measurementType)) &&
              ((whenPeriods.contains(ResultsWhenPeriod.today) &&
                      pResult.measurementDateTime?.isToday() == true) ||
                  (whenPeriods.contains(ResultsWhenPeriod.yesterday) &&
                      pResult.measurementDateTime?.wasYesterday() == true)));
        })
        .map(
          (pResult) => MeasurementResult(
            measurementDateTime: pResult.measurementDateTime!,
            value: getValueByMeasurement(pResult),
            composedValue: getComposedDoubleValue(pResult),
            sourceDevice: pResult.sourceDeviceWithMetadata?.sourceDevice,
            measurementType: pResult.measurementType,
            userId: pResult.patientMuid,
          ),
        )
        .toList();

    return measurementResults;
  }

  static ComposedDoubleValue? getComposedDoubleValue(Measurement measurement) {
    switch (measurement.measurementType) {
      case MeasurementType.bloodPressure:
        return ComposedDoubleValue(
          firstValue: measurement.bloodPressure?.systolic?.toDouble(),
          secondValue: measurement.bloodPressure?.diastolic?.toDouble(),
        );

      default:
        return null;
    }
  }

  static double? getValueByMeasurement(Measurement measurement) {
    switch (measurement.measurementType) {
      case MeasurementType.temperature:
        return measurement.temperature;
      case MeasurementType.oxygenSaturation:
        return measurement.oxygenSaturation != null
            ? measurement.oxygenSaturation!.toDouble()
            : null;
      case MeasurementType.heartRate:
        return measurement.heartRate != null
            ? measurement.heartRate!.toDouble()
            : null;
      case MeasurementType.respiratoryRate:
        return measurement.respiratoryRate != null
            ? measurement.respiratoryRate!.toDouble()
            : null;

      default:
        return null;
    }
  }
}
