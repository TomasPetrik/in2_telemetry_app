import 'package:collection/collection.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/mapper/measurement_type_mapper.dart';
import 'package:scalesoft_app/model/server_measurement_model.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/ui/widgets/interactive_chart/candle_data.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

class ResultsHelper {
  static MeasurementTypeMapper measurementTypeMapper = getIt<MeasurementTypeMapper>();

  static Map<ResultsWhenPeriod, int?> getPeriodFulfillments(
    List<CarePlan> carePlans,
    final List<Measurement> todayAndYesterdayResults,
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

  static List<PlannedMeasurement> getPlannedMeasurements(
    final List<CarePlan> allCarePlans,
    final ResultsWhenPeriod whenPeriod,
    final MeasurementType? measurementType,
    final List<Measurement> offlineResults,
  ) {
    List<PlannedMeasurement> measurements = [];

    final carePlans = measurementType != null
        ? allCarePlans
            .where(
              (carePlan) => carePlan.activity.measurementType == measurementType,
            )
            .toList()
        : allCarePlans;

    switch (whenPeriod) {
      case ResultsWhenPeriod.today:
        measurements = Calendar.getPlannedMeasurementsOfDay(
          carePlans: carePlans,
          dayDt: DateTime.now().date,
          offlineResults: offlineResults,
          all: true,
        );
        break;
      case ResultsWhenPeriod.yesterday:
        measurements = Calendar.getPlannedMeasurementsOfDay(
          carePlans: carePlans,
          dayDt: DateTime.now().yesterday,
          offlineResults: offlineResults,
          all: true,
        );
        break;
    }

    measurements.sort(
      (a, b) => a.whenStart.millisecondsSinceEpoch.compareTo(b.whenStart.millisecondsSinceEpoch),
    );

    return measurements;
  }

  static List<MeasurementResultViewModel> getResultsOfDay({
    required final List<PlannedMeasurement> plannedMeasurements,
    required final List<Measurement> measurements,
    required final DateTime startOfDay,
    required final List<UserModel> users,
    final List<ServerMeasurementModel>? serverMeasurements,
  }) {
    final List<MeasurementResultViewModel> allResults = [];

    final resultsUntilNow =
        plannedMeasurements.fold<List<MeasurementResultViewModel>>([], (prevMeasurements, plannedMeasurement) {
      List<MeasurementResultViewModel> results = [];

      final evaluationItem = plannedMeasurement.fulfillmentEvaluationItem!;

      final measurementTimes = evaluationItem.actualMeasurementTimes
          .where((time) => time.isAfterOrAt(startOfDay) && time.isBefore(startOfDay.endOfDay));
      // Add one item per measurement time
      // If requiredCount > actualCount, add another item representing the remaining measurements
      final user = users.firstWhere((x) => x.id == plannedMeasurement.userId);

      for (final measurementTime in measurementTimes) {
        results.add(
          MeasurementResultViewModel(
            plannedMeasurement.measurementType,
            measurementTime,
            user,
            1,
            1,
            plannedMeasurement.whenCode,
            measurementIntervalStart: plannedMeasurement.fulfillmentEvaluationItem?.start,
            measurementIntervalEnd: plannedMeasurement.fulfillmentEvaluationItem?.end,
            wasPlanned: true,
          ),
        );
      }

      if (plannedMeasurement.reqCount > evaluationItem.actualMeasurementCount) {
        results.add(
          MeasurementResultViewModel(
            plannedMeasurement.measurementType,
            plannedMeasurement.whenStart,
            user,
            plannedMeasurement.reqCount,
            evaluationItem.actualMeasurementCount,
            plannedMeasurement.whenCode,
            measurementIntervalStart: plannedMeasurement.fulfillmentEvaluationItem?.start,
            measurementIntervalEnd: plannedMeasurement.fulfillmentEvaluationItem?.end,
            wasPlanned: true,
          ),
        );
      }

      return [
        ...prevMeasurements,
        ...results,
      ];
    });

    allResults.addAll(resultsUntilNow);

    //3. Add other patient/measurement (s) not included in previous ongoing resolved results;
    // Add measured values to existing results.
    for (final measurement in measurements) {
      final matchingResults = resultsUntilNow.where(
        (x) =>
            x.measurementTime.isAtSameMomentAs(measurement.measuredAt) &&
            x.measurementType == measurement.measurementType &&
            x.user.id == measurement.userId,
      );

      if (matchingResults.isEmpty &&
          measurement.measuredAt.isAfterOrAt(startOfDay) &&
          measurement.measuredAt.isBefore(startOfDay.endOfDay)) {
        allResults.add(
          MeasurementResultViewModel(
            measurement.measurementType,
            measurement.measuredAt,
            users.firstWhere((x) => x.id == measurement.userId),
            1,
            1,
            null,
            result: MeasurementHelper.measurementToString(measurement),
          ),
        );
      } else {
        for (final computedResult in matchingResults) {
          computedResult.result = MeasurementHelper.measurementToString(measurement);
        }
      }
    }

    // Add server results, if any
    for (final ServerMeasurementModel measurement in serverMeasurements ?? []) {
      final matchingResults = resultsUntilNow.where(
        (x) =>
            x.measurementTime.isAtSameMomentAs(measurement.measurementDateTime) &&
            x.measurementType == measurement.measurementType &&
            x.user.id == measurement.userId,
      );

      if (matchingResults.isEmpty &&
          measurement.measurementDateTime.isAfterOrAt(startOfDay) &&
          measurement.measurementDateTime.isBefore(startOfDay.endOfDay)) {
        allResults.add(
          MeasurementResultViewModel(
            measurement.measurementType,
            measurement.measurementDateTime,
            users.firstWhere((x) => x.id == measurement.userId),
            1,
            1,
            null,
            result: measurement.formattedValue,
          ),
        );
      } else {
        for (final computedResult in matchingResults) {
          computedResult.result = measurement.formattedValue;
        }
      }
    }

    return allResults.sortedBy((x) => x.measurementIntervalStart ?? x.measurementTime);
  }

  static List<MeasurementResultViewModel> getResultsByWhenPeriod({
    required final List<CarePlan> carePlans,
    required final ResultsWhenPeriod whenPeriod,
    required final List<Measurement> allOfflineResults,
    required final List<UserModel> users,
    MeasurementType? measurementType,
  }) {
    final dtNow = DateTime.now();

    final yesterdayMidnight = dtNow.yesterday;
    final todayMidnight = dtNow.date;
    final tomorrowMidnight = dtNow.tomorrow;

    final offlineResults = allOfflineResults.where((offlineResult) {
      return (measurementType == null || measurementType == offlineResult.measurementType) &&
          ((whenPeriod == ResultsWhenPeriod.today &&
                  offlineResult.measuredAt.isBefore(tomorrowMidnight) &&
                  offlineResult.measuredAt.isAfter(todayMidnight)) ||
              (whenPeriod == ResultsWhenPeriod.yesterday &&
                  offlineResult.measuredAt.isBefore(todayMidnight) &&
                  offlineResult.measuredAt.isAfter(yesterdayMidnight)));
    }).toList();

    //1. Get results within current time
    final List<PlannedMeasurement> plannedMeasurements = getPlannedMeasurements(
      carePlans,
      whenPeriod,
      measurementType,
      offlineResults,
    );

    final pMeasurementsUntilNow = plannedMeasurements.where((measurement) {
      return measurement.whenEnd.isBefore(dtNow) ||
          measurement.fulfillmentEvaluationItem!.actualMeasurementCount >=
              measurement.fulfillmentEvaluationItem!.requiredMeasurementCount; //it's finished measurement
    }).toList();

    final resultsOfDay = getResultsOfDay(
      plannedMeasurements: pMeasurementsUntilNow,
      measurements: offlineResults,
      startOfDay: whenPeriod == ResultsWhenPeriod.today ? todayMidnight : yesterdayMidnight,
      users: users,
    );

    // Filter out unsupported metrics - usually battery measurements.
    return resultsOfDay
        .where((x) => x.wasPlanned || x.user.hospital.enabledMeasurementTypes.contains(x.measurementType))
        .toList();
  }

  static CandleData getCandleByMeasurementResult(
    MeasurementDataContract measurement,
  ) {
    final MeasurementType measurementType = measurementTypeMapper.convert(measurement.measurementType);

    switch (measurement.measurementType) {
      case MeasurementTypeContract.temperature:
        return CandleData(
          measurementType: measurementType,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementTypeContract.bloodPressure:
        return CandleData(
          measurementType: measurementType,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.composedValue?.firstValue,
          low: measurement.composedValue?.secondValue,
        );

      case MeasurementTypeContract.oxygenSaturation:
        return CandleData(
          measurementType: measurementType,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementTypeContract.heartRate:
        return CandleData(
          measurementType: measurementType,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementTypeContract.respiratoryRate:
        return CandleData(
          measurementType: measurementType,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementTypeContract.shortnessOfBreath:
        return CandleData(
          measurementType: measurementType,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementTypeContract.overallHealth:
        return CandleData(
          measurementType: measurementType,
          timestamp: measurement.measurementDateTime.millisecondsSinceEpoch,
          high: measurement.value,
          low: 0,
        );
      case MeasurementTypeContract.steps:
      case MeasurementTypeContract.globalPosition:
      case MeasurementTypeContract.ews:
      case MeasurementTypeContract.battery:
        return CandleData(
          measurementType: measurementType,
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
          timestamp: measurement.measuredAt.millisecondsSinceEpoch,
          high: measurement.temperature,
          low: 0,
        );
      case MeasurementType.bloodPressure:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measuredAt.millisecondsSinceEpoch,
          high: measurement.bloodPressure?.systolic?.toDouble(),
          low: measurement.bloodPressure?.diastolic?.toDouble(),
        );

      case MeasurementType.oxygenSaturation:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measuredAt.millisecondsSinceEpoch,
          high: measurement.oxygenSaturation?.toDouble(),
          low: 0,
        );
      case MeasurementType.heartRate:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measuredAt.millisecondsSinceEpoch,
          high: measurement.heartRate?.toDouble(),
          low: 0,
        );
      case MeasurementType.respiratoryRate:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measuredAt.millisecondsSinceEpoch,
          high: measurement.respiratoryRate?.toDouble(),
          low: 0,
        );
      case MeasurementType.shortnessOfBreath:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measuredAt.millisecondsSinceEpoch,
          high: measurement.shortnessOfBreath?.index.toDouble(),
          low: 0,
        );
      case MeasurementType.overallHealth:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measuredAt.millisecondsSinceEpoch,
          high: measurement.shortnessOfBreath?.index.toDouble(),
          low: 0,
        );
      case MeasurementType.steps:
      case MeasurementType.globalPosition:
      case MeasurementType.ews:
      case MeasurementType.battery:
        return CandleData(
          measurementType: measurement.measurementType,
          timestamp: measurement.measuredAt.millisecondsSinceEpoch,
          high: null,
          low: null,
        );
    }
  }
}
