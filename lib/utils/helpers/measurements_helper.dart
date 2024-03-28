import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/contracts/measurement/composed_value_contract.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';
import 'package:scalesoft_app/mapper/measurement_type_mapper.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_measurement_route.dart';
import 'package:scalesoft_app/ui/routers/routes/metering_first_route.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class MeasurementHelper {
  static MeasurementTypeMapper measurementTypeMapper = getIt<MeasurementTypeMapper>();

  static void doMeasurement({
    required final BuildContext context,
    required final int userId,
    final MeasurementType? selectedMeasurementType,
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
              (supportedDevice) => supportedDevice.supportedMeasurementTypes.contains(selectedMeasurementType),
            )) {
      GoRouter.of(context).pushNamed(
        MeteringFirstRoute.name,
        params: {
          'userId': userId.toString(),
          'measurementType': selectedMeasurementType != null ? selectedMeasurementType.name : 'anyType',
          'showAllMeasurementTypes': showAllMeasurementTypes.toString(),
        },
      );
    } else {
      GoRouter.of(context).pushNamed(
        ManualMeasurementRoute.name,
        params: {
          'userId': userId.toString(),
          'measurementType': selectedMeasurementType.name,
          'showAllMeasurementTypes': showAllMeasurementTypes.toString(),
        },
      );
    }
  }

  static FulfillmentEvaluationItem getFulfillmentEvaluation(
    PlannedMeasurement plannedMeasurement,
    List<Measurement> measurements,
    List<FulfillmentEvaluationItem> evaluationItems,
  ) {
    int totalCount = 0;
    List<DateTime> measuredTimes = [];

    //get all datetimes in last two days
    final measurementTimes = evaluationItems.fold<List<DateTime>>(
      [],
      (previousValue, evItem) => [...previousValue, ...evItem.actualMeasurementTimes],
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
    final matchedOfflineMeasurementTimes = measurements.where(
      (mResult) {
        return mResult.measurementType == plannedMeasurement.measurementType &&
            mResult.userId == plannedMeasurement.userId;
      },
    ).map((mResult) => mResult.measuredAt);

    for (final measuredTime in matchedOfflineMeasurementTimes) {
      if (measuredTime.isBefore(plannedMeasurement.whenEnd) && measuredTime.isAfter(plannedMeasurement.whenStart)) {
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

  static List<Measurement> filterMeasurements(
    List<Measurement> pendingResults,
    List<ResultsWhenPeriod>? whenPeriods,
    MeasurementType? measurementType,
  ) {
    //offline (not synced results)
    final measurementResults = pendingResults
        .where((pResult) {
          return ((measurementType == null || (measurementType == pResult.measurementType)) &&
              (whenPeriods == null ||
                  (whenPeriods.contains(ResultsWhenPeriod.today) && pResult.measuredAt.isToday == true) ||
                  (whenPeriods.contains(ResultsWhenPeriod.yesterday) && pResult.measuredAt.wasYesterday == true)));
        })
        .toList();

    return measurementResults;
  }

  static ComposedValueContract? getComposedDoubleValue(Measurement measurement) {
    switch (measurement.measurementType) {
      case MeasurementType.bloodPressure:
        return ComposedValueContract(
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
        return measurement.oxygenSaturation?.toDouble();
      case MeasurementType.heartRate:
        return measurement.heartRate?.toDouble();
      case MeasurementType.respiratoryRate:
        return measurement.respiratoryRate?.toDouble();
      case MeasurementType.shortnessOfBreath:
        return measurement.shortnessOfBreath?.value.toDouble();
      case MeasurementType.overallHealth:
        return measurement.overallHealth?.value.toDouble();
      default:
        return null;
    }
  }

  static String measurementToString(Measurement measurement) {
    final value = switch (measurement.measurementType) {
      MeasurementType.temperature => measurement.temperature.toString(),
      MeasurementType.bloodPressure =>
        "${measurement.bloodPressure?.systolic ?? 'N/A'}/${measurement.bloodPressure?.diastolic ?? 'N/A'}",
      MeasurementType.oxygenSaturation => measurement.oxygenSaturation.toString(),
      MeasurementType.heartRate => measurement.heartRate.toString(),
      MeasurementType.respiratoryRate => measurement.respiratoryRate.toString(),
      MeasurementType.shortnessOfBreath => measurement.shortnessOfBreath != null
          ? localization.shortness_of_breath_values(measurement.shortnessOfBreath!)
          : "",
      MeasurementType.overallHealth =>
        measurement.overallHealth != null ? localization.overall_health_values(measurement.overallHealth!) : "",
      MeasurementType.ews || MeasurementType.steps || MeasurementType.globalPosition || MeasurementType.battery => "",
    };

    return "$value ${localization.common_measurement_units_types(measurement.measurementType)}";
  }
}
