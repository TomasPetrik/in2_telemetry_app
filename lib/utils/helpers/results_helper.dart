import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class ResultsHelper {
  static Map<ResultsWhenPeriod, int> getPeriodFultillments(
    List<CarePlan> carePlans,
  ) {
    return {
      ResultsWhenPeriod.yesterday: EvaluationPlanHelper.getProgressFromPlans(
        carePlans: carePlans,
        whenPeriod: ResultsWhenPeriod.yesterday,
      ),
      ResultsWhenPeriod.today: EvaluationPlanHelper.getProgressFromPlans(
        carePlans: carePlans,
        whenPeriod: ResultsWhenPeriod.today,
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
          weekDay: DateTime.now().currentWeekDay(),
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
    required final List<Measurement> pendingResults,
    MeasurementType? measurementType,
  }) {
    //1. create list of results matching whenPeriod

    List<MeasurementResult> results = MeasurementHelper.getResults(
      measurementResults,
      pendingResults,
      whenPeriod,
      measurementType,
    );

    //2. get planned measurements matching whenPeriod
    final List<PlannedMeasurement> plannedMeasurements =
        getMeasurements(carePlans, whenPeriod, measurementType);

    final dtNow = DateTime.now();
    final notMeasuredResults = plannedMeasurements
        .where((measurement) {
          return measurement.whenEnd.isBefore(dtNow);
        })
        .where(
          (measurement) =>
              MeasurementHelper.wasMeasured(measurement, results) == false,
        )
        .map(
          (measurement) => MeasurementResult(
            measurementDateTime: measurement.whenStart,
            measurementFinishDateTime: measurement.whenEnd,
            wasMeasured: false,
            measurementType: measurement.carePlan.activity.measurementType,
          ),
        );

    results.addAll(notMeasuredResults);

    results.sort((a, b) {
      final dtA = a.measurementFinishDateTime ?? a.measurementDateTime;
      final dtB = b.measurementFinishDateTime ?? b.measurementDateTime;

      return dtB.millisecondsSinceEpoch.compareTo(dtA.millisecondsSinceEpoch);
    });

    //3. Find if this planned measurements are covered by times from measurement lists

    //4. Create then unmeasured result items and add them into list, (use timeEnd time for ordering)

    //5. order list by time.

    return results;
  }

/*
  static Set<DateTime> getResultsDateTimes(Da){
    final measuredTimesSet = measurementResults
        .where(
          (mResult) =>
              mResult.measurementType == carePlan.activity.measurementType,
        )
        .map((mResult) => mResult.measurementDateTime);
  }
  */
}

class Result {}
