import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_double_value.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class MeasurementHelper {
  static bool wasMeasured(
    PlannedMeasurement plannedMeasurement,
    List<MeasurementResult> measurementResults,
  ) {
    final measuredTimesSet = measurementResults
        .where(
          (mResult) =>
              mResult.measurementType ==
              plannedMeasurement.carePlan.activity.measurementType,
        )
        .map((mResult) => mResult.measurementDateTime);

    for (final measuredTime in measuredTimesSet) {
      if (plannedMeasurement.whenStart.isBefore(measuredTime) &&
          plannedMeasurement.whenEnd.isAfter(measuredTime)) {
        return true;
      }
    }

    return false;
  }

  static List<MeasurementResult> getResults(
    List<MeasurementResult> measurementResults,
    List<Measurement> pendingResults,
    ResultsWhenPeriod whenPeriod,
    MeasurementType? measurementType,
  ) {
    List<MeasurementResult> results = measurementResults.where((mResult) {
      return ((measurementType == null ||
              (measurementType == mResult.measurementType)) &&
          ((whenPeriod == ResultsWhenPeriod.today &&
                  mResult.measurementDateTime.isToday()) ||
              (whenPeriod == ResultsWhenPeriod.yesterday &&
                  mResult.measurementDateTime.wasYesterday())));
    }).toList();

    //include not synced results
    final filteredPendingResults = pendingResults
        .where((pResult) {
          return ((measurementType == null ||
                  (measurementType == pResult.measurementType)) &&
              ((whenPeriod == ResultsWhenPeriod.today &&
                      pResult.measurementDateTime?.isToday() == true) ||
                  (whenPeriod == ResultsWhenPeriod.yesterday &&
                      pResult.measurementDateTime?.wasYesterday() == true)));
        })
        .map(
          (pResult) => MeasurementResult(
            measurementDateTime: pResult.measurementDateTime!,
            value: getValueByMeasurement(pResult),
            composedValue: getComposedDoubleValue(pResult),
            sourceDevice: pResult.sourceDeviceWithMetadata?.sourceDevice,
            wasMeasured: true,
            measurementType: pResult.measurementType,
          ),
        )
        .toList();

    results.addAll(filteredPendingResults);

    return results;
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
