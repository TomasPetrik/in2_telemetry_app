import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/calendar_evaluation_db_provider.dart';
import 'package:scalesoft_app/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';

class EvaluationPlanHelper {
  static int getProgressFromFullPlanEvaluation({
    required CarePlan carePlan,
    required List<MeasurementResult> offlineResults,
  }) {
    int actualCount = carePlan.fullPlanEvaluation!.measurementInPlanCount;
    int requiredMeasurementCount =
        carePlan.fullPlanEvaluation!.requiredMeasurementCount;

    int offlineResultsCount = 0;

    if (offlineResults.isNotEmpty) {
      //get all planned measurements within current time since plan exists
      final allPlannedMeasurements =
          CarePlanHelper.getPlannedMeasurementsUpToToday(
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
              (offlineResult) => offlineResult.measurementDateTime == legitDt,
            ),
          )
          .length;
    }

    int allActualCount = actualCount + offlineResultsCount;
    requiredMeasurementCount = allActualCount > requiredMeasurementCount
        ? allActualCount
        : requiredMeasurementCount;

    int percentage = requiredMeasurementCount == 0
        ? 0
        : (allActualCount / requiredMeasurementCount * 100).round();
    return percentage;
  }

  static int? getProgressFromPlans({
    required List<CarePlan> carePlans,
    required ResultsWhenPeriod whenPeriod,
    required List<MeasurementResult> offlineResults,
  }) {
    int expectedCount = 0;
    int actualCount = 0;

    final List<PlannedMeasurement> plannedMeasurements =
        ResultsHelper.getMeasurements(
      carePlans,
      whenPeriod,
      null,
      offlineResults,
    );

    final dtNow = DateTime.now();
    final dayFinishAt = whenPeriod == ResultsWhenPeriod.today
        ? dtNow.getTomorrowMidnight()
        : dtNow.getTodayMidnight();

    //filter out periodical measurement
    //which are not ending within exact day,
    //and they still haven't been fulfilled until measurement's finish time
    plannedMeasurements.removeWhere(
      (pMeasurement) =>
          pMeasurement.carePlan.isPeriodical &&
          (!pMeasurement.whenEnd.isBefore(dayFinishAt) &&
              !pMeasurement.fulfillmentEvaluationItem!.wasMeasured()),
    );

    for (final plannedMeasurement in plannedMeasurements) {
      expectedCount += plannedMeasurement.reqCount;
      actualCount += plannedMeasurement.currentCount == null
          ? 0
          : plannedMeasurement.currentCount! > plannedMeasurement.reqCount
              ? plannedMeasurement.reqCount
              : plannedMeasurement.currentCount!;
    }

    return expectedCount == 0
        ? null
        : (actualCount / expectedCount * 100).round();
  }

  static int getProgressFromEvaluationItems(
    List<FulfillmentEvaluationItem> items,
  ) {
    if (items.isEmpty) return 0;

    //1. Get required count
    final allRequiredMeasurementCount = items
        .map((evItem) => evItem.requiredMeasurementCount)
        .reduce((prevVal, nextVal) => prevVal + nextVal);

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

    return (allActualMeasurementCount / allRequiredMeasurementCount * 100)
        .round();
  }

  static List<UserEvaluationDay> getUserEvaluationDays(
    final int year,
    final int month,
    final CalendarDay day,
    final List<UserAccount> userAccounts,
    final MeasurementsDbProvider measurementsDbProvider,
  ) {
    final CalendarEvaluationDbProvider calendarDbProvider =
        getIt<CalendarEvaluationDbProvider>();
    final PendingResultsDbProvider pendingResultsDbProvider =
        getIt<PendingResultsDbProvider>();
    final List<UserEvaluationDay> userEvDays = [];

    for (final userAccount in userAccounts) {
      final List<Measurement> offlineMeasurements =
          pendingResultsDbProvider.getPerUser(userAccount.user.muid);

      final List<MeasurementResult> offlineResults =
          MeasurementHelper.getOffilneResultsConverted(
        offlineMeasurements,
        null,
        null,
      );

      final List<SingleDayMeasurementsOfExactType> carePlanFulfillments = [];

      Set<MeasurementType> measurementTypes = userAccount.carePlans!
          .map((carePlan) => carePlan.activity.measurementType)
          .toSet();

      for (final measurementType in measurementTypes) {
        final List<MeasurementResult> serverResultsOfExactType =
            measurementsDbProvider
                    .get(
                      userAccount.user.muid,
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

        final carePlansOfExactType = userAccount.carePlans!
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
          userAccount.user.fullName,
          day.dayPeriod,
        );
        userEvDays.add(userEvaluationDay);
      }
    }

    return userEvDays;
  }
}
