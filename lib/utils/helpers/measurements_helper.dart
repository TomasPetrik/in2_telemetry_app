import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_measurement_route.dart';
import 'package:scalesoft_app/ui/routers/routes/metering_first_route.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class MeasurementHelper {
  static void doMeasurement({
    required final BuildContext context,
    required final String userId,
    final MeasurementTypeContract? selectedMeasurementType,
    final bool showAllMeasurementTypes = false,
  }) async {
    if (selectedMeasurementType == null ||
        ConfigurationConstants.supportedDevices
            .where(
              (x) =>
                  x.measurementFlow?.hasFlag(MeasurementFlow.foreground) ??
                  false,
            )
            .any(
              (supportedDevice) => supportedDevice.supportedMeasurementTypes!
                  .contains(selectedMeasurementType),
            )) {
      GoRouter.of(context).pushNamed(
        MeteringFirstRoute.name,
        params: {
          'userId': userId,
          'measurementType': selectedMeasurementType != null
              ? selectedMeasurementType.name
              : 'anyType',
          'showAllMeasurementTypes': showAllMeasurementTypes.toString(),
        },
      );
    } else {
      GoRouter.of(context).pushNamed(
        ManualMeasurementRoute.name,
        params: {
          'userId': userId,
          'measurementType': selectedMeasurementType.name,
          'showAllMeasurementTypes': showAllMeasurementTypes.toString(),
        },
      );
    }
  }

  static FulfillmentEvaluationItem getFulfillmentEvaluation(
    PlannedMeasurement plannedMeasurement,
    List<MeasurementResult> offlineResults,
  ) {
    int totalCount = 0;
    List<DateTime> measuredTimes = [];

    List<FulfillmentEvaluationItem> evItems =
        plannedMeasurement.carePlan.serverEvaluationItems ?? [];

    //get all datetimes in last two days
    final measurementTimes = evItems.fold<List<DateTime>>(
      [],
      (previousValue, evItem) =>
          [...previousValue, ...evItem.actualMeasurementTimes],
    );

    //filter them by matching exact measurement time
    final matchedMeasurementTimes = measurementTimes
        .where(
          (measurementTime) =>
              measurementTime.isBefore(plannedMeasurement.whenEnd) &&
              measurementTime.isAfter(plannedMeasurement.whenStart),
        )
        .toList();

    if (matchedMeasurementTimes.isNotEmpty == true) {
      measuredTimes.addAll(matchedMeasurementTimes);
    }
    totalCount = measuredTimes.length;

    //if we are already satisfied from server side
    if (plannedMeasurement.reqCount <= totalCount) {
      return FulfillmentEvaluationItem(
        plannedMeasurement.whenStart,
        plannedMeasurement.whenEnd,
        plannedMeasurement.reqCount,
        totalCount,
        measuredTimes.take(plannedMeasurement.reqCount).toList(),
      );
    }

    //otherwise check offline results
    final matchedOfflineMeasurementTimes = offlineResults.where(
      (mResult) {
        return mResult.measurementType ==
                plannedMeasurement.carePlan.activity.measurementType &&
            mResult.userId == plannedMeasurement.userId;
      },
    ).map((mResult) => mResult.measurementDateTime);

    for (final measuredTime in matchedOfflineMeasurementTimes) {
      if (measuredTime.isBefore(plannedMeasurement.whenEnd) &&
          measuredTime.isAfter(plannedMeasurement.whenStart)) {
        measuredTimes.add(measuredTime);
        totalCount += 1;
      }
    }

    final minSatisfiedCount = min(totalCount, plannedMeasurement.reqCount);

    return FulfillmentEvaluationItem(
      plannedMeasurement.whenStart,
      plannedMeasurement.whenEnd,
      plannedMeasurement.reqCount,
      totalCount,
      measuredTimes.take(minSatisfiedCount).toList(),
    );
  }

  static List<MeasurementResult> getResults(
    List<MeasurementResult> measurementResults,
    List<Measurement> pendingResults,
    List<ResultsWhenPeriod> whenPeriods,
    MeasurementTypeContract? measurementType,
  ) {
    List<MeasurementResult> results = measurementResults.where((mResult) {
      return ((measurementType == null ||
              (measurementType == mResult.measurementType)) &&
          ((whenPeriods.contains(ResultsWhenPeriod.today) &&
                  mResult.measurementDateTime.isToday) ||
              (whenPeriods.contains(ResultsWhenPeriod.yesterday) &&
                  mResult.measurementDateTime.wasYesterday)));
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
    List<ResultsWhenPeriod>? whenPeriods,
    MeasurementTypeContract? measurementType,
  ) {
    //offline (not synced results)
    final measurementResults = pendingResults
        .where((pResult) {
          return ((measurementType == null ||
                  (measurementType == pResult.measurementType)) &&
              (whenPeriods == null ||
                  (whenPeriods.contains(ResultsWhenPeriod.today) &&
                      pResult.measurementDateTime?.isToday == true) ||
                  (whenPeriods.contains(ResultsWhenPeriod.yesterday) &&
                      pResult.measurementDateTime?.wasYesterday == true)));
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
      case MeasurementTypeContract.bloodPressure:
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
      case MeasurementTypeContract.temperature:
        return measurement.temperature;
      case MeasurementTypeContract.oxygenSaturation:
        return measurement.oxygenSaturation?.toDouble();
      case MeasurementTypeContract.heartRate:
        return measurement.heartRate?.toDouble();
      case MeasurementTypeContract.respiratoryRate:
        return measurement.respiratoryRate?.toDouble();
      case MeasurementTypeContract.shortnessOfBreath:
        return measurement.shortnessOfBreath?.value.toDouble();
      case MeasurementTypeContract.overallHealth:
        return measurement.overallHealth?.value.toDouble();
      default:
        return null;
    }
  }
}
