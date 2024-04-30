import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';

class EvaluationPlanHelper {
  static int getProgressFromFullPlanEvaluation({
    required CarePlanContract carePlan,
    required List<MeasurementDataContract> offlineResults,
    required CarePlan carePlan,
    required List<Measurement> offlineResults,
  }) {
    int actualCount = carePlan.fullPlanEvaluation!.measurementInPlanCount;
    int requiredMeasurementCount =
        carePlan.fullPlanEvaluation!.requiredMeasurementCount;
    int actualCount = carePlan.fullPlanEvaluation.measurementInPlanCount;
    int requiredMeasurementCount = carePlan.fullPlanEvaluation.requiredMeasurementCount;

    int offlineResultsCount = 0;

    if (offlineResults.isNotEmpty) {
      //get all planned measurements within current time since plan exists
      final allPlannedMeasurements = CarePlanHelper.getPlannedMeasurementsUpToToday(
        carePlan,
        offlineResults,
      );

      //check if offline results are included in these measurements
      final allLegitDateTimes = allPlannedMeasurements.fold<List<DateTime>>(
        [],
        (prevDateTimes, plMeasurement) => [
          ...prevDateTimes,
          ...plMeasurement.fulfillmentEvaluationItem!.actualMeasurementTimes,
        ],
      ).toSet();
      offlineResultsCount = allLegitDateTimes
          .where(
            (legitDt) => offlineResults.any(
              (offlineResult) => offlineResult.measuredAt.isAtSameMomentAs(legitDt),
            ),
          )
          .length;
    }

    int allActualCount = actualCount + offlineResultsCount;
    requiredMeasurementCount = allActualCount > requiredMeasurementCount ? allActualCount : requiredMeasurementCount;

    int percentage = requiredMeasurementCount == 0 ? 0 : (allActualCount / requiredMeasurementCount * 100).round();
    return percentage;
  }

  static int? getProgressFromPlans({
    required List<CarePlan> carePlans,
    required ResultsWhenPeriod whenPeriod,
    required List<Measurement> offlineResults,
  }) {
    int expectedCount = 0;
    int actualCount = 0;

    final List<PlannedMeasurement> plannedMeasurements = ResultsHelper.getPlannedMeasurements(
      carePlans,
      whenPeriod,
      null,
      offlineResults,
    );

    for (final plannedMeasurement in plannedMeasurements) {
      expectedCount += plannedMeasurement.reqCount;
      actualCount += plannedMeasurement.currentCount == null
          ? 0
          : plannedMeasurement.currentCount! > plannedMeasurement.reqCount
              ? plannedMeasurement.reqCount
              : plannedMeasurement.currentCount!;
    }

    return expectedCount == 0 ? null : (actualCount / expectedCount * 100).round();
  }

  static int getProgressFromEvaluationItems(
    List<FulfillmentEvaluationItem> items,
  ) {
    if (items.isEmpty) return 0;

    //1. Get required count
    final allRequiredMeasurementCount =
        items.map((evItem) => evItem.requiredMeasurementCount).reduce((prevVal, nextVal) => prevVal + nextVal);

    //1. Get current measurement count
    final measurementTimes = items.fold<List<DateTime>>(
      [],
      (prevEvTimes, evItem) => [
        ...prevEvTimes,
        ...evItem.actualMeasurementTimes,
      ],
    );

    //2. Make sure they are unique
    final measurementTimesSet = measurementTimes.toSet();
    final allActualMeasurementCount = measurementTimesSet.length;

    return (allActualMeasurementCount / allRequiredMeasurementCount * 100).round();
  }

  static List<UserEvaluationDay> getUserEvaluationDays(
    final int year,
    final int month,
    final List<CarePlan> allUsersCarePlans,
    final CalendarDay day,
    final List<UserAccount> userAccountsOfDay,
    final MeasurementsDbProvider measurementsDbProvider,
  ) {
    final CalendarEvaluationDbProvider calendarDbProvider =
        getIt<CalendarEvaluationDbProvider>();
    final PendingResultsDbProvider pendingResultsDbProvider =
        getIt<PendingResultsDbProvider>();
    final List<UserEvaluationDay> userEvDays = [];

    for (final userAccountOfDay in userAccountsOfDay) {
      final List<Measurement> offlineMeasurements =
          pendingResultsDbProvider.getPerUser(userAccountOfDay.user.muid);

      final List<MeasurementDataContract> offlineResults =
          MeasurementHelper.getOffilneResultsConverted(
        offlineMeasurements,
        null,
        null,
      );

      final List<SingleDayMeasurementsOfExactType> carePlanFulfillments = [];

      final userCarePlansOfDay = allUsersCarePlans.where((carePlan) => carePlan.userId == userAccountOfDay.user.muid).toList();

      Set<MeasurementTypeContract> measurementTypes = userAccount.carePlans!
          .map((carePlan) => carePlan.activity.measurementType)
          .toSet();

      for (final measurementType in measurementTypes) {
        final List<MeasurementDataContract> serverResultsOfExactType =
            measurementsDbProvider
                    .get(
                      userAccountOfDay.user.muid,
                      measurementType,
                      year,
                      month,
                    )
                    ?.items
                    .where(
                      (result) =>
                          result.measurementDateTime.isBefore(day.endDt) &&
                          result.measurementDateTime.isAfter(day.startDt),
                    )
                    .toList() ??
                [];

        final carePlansOfExactType = userCarePlansOfDay
            .where(
              (carePlan) =>
                  carePlan.activity.measurementType == measurementType,
            )
            .toList();

        for (final carePlan in carePlansOfExactType) {
          final monthlyEvItems = calendarDbProvider
              .get(
                carePlan.id,
                year,
                month,
              )
              ?.items;

          if (monthlyEvItems != null) {
            carePlan.addEvaluationItems(monthlyEvItems);
          }
        }

        final List<PlannedMeasurement> plannedMeasurements =
            Calendar.getMeasurementsOfDay(
          carePlans: carePlansOfExactType,
          dayDt: day.startDt,
          offlineResults: offlineResults,
          all: true,
        );

        //get list of MeasurementResult as this method is about to get historical results
        final measurementResultsOfExactType = ResultsHelper.getResultsOfDay(
          plannedMeasurements: plannedMeasurements,
          serverResults: serverResultsOfExactType,
          offlineResults: offlineResults,
          startOfDay: day.startDt,
        );

        /*
        debugPrint(
          'user ${userAccount.user.fullName}, plan ${carePlan.id}, ev items ${evItems.length} in day: ${day.startDt.toRegularDate()}',
        );
        */

        final carePlanSingleEvaluation = SingleDayMeasurementsOfExactType(
          measurementType,
          plannedMeasurements,
          offlineMeasurements,
          measurementResultsOfExactType,
        );

/*
        debugPrint(
          '${day.startDt.toRegularDate()} ${carePlan.activity.measurementType.name} measurements : ${carePlanSingleEvaluation.getActualCount()} / ${carePlanSingleEvaluation.getReqCount()}',
        );
        */

        carePlanFulfillments.add(carePlanSingleEvaluation);
      }

      if (carePlanFulfillments.isNotEmpty) {
        final userEvaluationDay = UserEvaluationDay(
          carePlanFulfillments,
          day.startDt,
          userAccountOfDay.user.fullName,
          day.dayPeriod,
        );
        userEvDays.add(userEvaluationDay);
      }
    }

    return userEvDays;
  }
}
