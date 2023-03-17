import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaulation_aggregated.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/calendar_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';

class EvaluationPlanHelper {
  static int getProgressFromFullPlanEvaluation(
    FulfillmentEvaluationAggregated fullPlanEvaluation,
  ) {
    int actualCount = fullPlanEvaluation.measurementInPlanCount;
    int requiredMeasurementCount = fullPlanEvaluation.requiredMeasurementCount;

    //TODO.. here should be included also offline results if this plan contains planned measurements
    //and their intervals are matching with offline results

    int percentage = requiredMeasurementCount == 0
        ? requiredMeasurementCount
        : (actualCount / requiredMeasurementCount * 100).round();
    return percentage;
  }

  static int getProgressFromEvaluation(
    FulfillmentEvaluation fulfillmentEvaluation,
  ) {
    return getProgressFromEvaluationItems(fulfillmentEvaluation.items);
  }

  static int? getProgressFromPlans({
    required List<CarePlan> carePlans,
    required List<MeasurementResult> offlineResults,
    required ResultsWhenPeriod whenPeriod,
  }) {
    int expectedCount = 0;
    int actualCount = 0;

    final List<PlannedMeasurement> plannedMeasurements =
        ResultsHelper.getMeasurements(
      carePlans,
      whenPeriod,
      null,
    );

    for (final plannedMeasurement in plannedMeasurements) {
      expectedCount += plannedMeasurement.reqCount;
    }

    //Include fulfillments evaluation items
    for (final carePlan in carePlans) {
      if (carePlan.lastTwoDaysEvaluation?.items.isNotEmpty == true) {
        for (final evItem in carePlan.lastTwoDaysEvaluation!.items) {
          if ((whenPeriod == ResultsWhenPeriod.today &&
                  evItem.start.isToday()) ||
              (whenPeriod == ResultsWhenPeriod.yesterday &&
                  evItem.start.wasYesterday())) {
            actualCount +=
                evItem.actualMeasurementCount > evItem.requiredMeasurementCount
                    ? evItem.requiredMeasurementCount
                    : evItem.actualMeasurementCount;
          }
        }
      }
    }

    //Include offline results if exists into plan fulfillment evaluation:

    //1. get planned measurements by careplan within current time inlcude ongoing results

    final dtNow = DateTime.now();
    final plannedMeasurementsWithingCurrentTime =
        plannedMeasurements.where((measurement) {
      return measurement.whenStart.isBefore(dtNow);
    }).toList();

    //2. check their expected frequency in interval
    for (final plannedMeasurement in plannedMeasurementsWithingCurrentTime) {
      //3. then look if offline results matching this period and measurementType
      final matchingResultsInPeriod = offlineResults.where((offlineResult) {
        return (offlineResult.measurementType ==
                plannedMeasurement.carePlan.activity.measurementType &&
            plannedMeasurement.hasMeasurementAt(
              offlineResult.measurementDateTime,
            ));
      });

      //4. Add offline measurements count to actualCount with overflow check
      if (matchingResultsInPeriod.isNotEmpty) {
        final maxIntervalCount =
            matchingResultsInPeriod.length > plannedMeasurement.reqCount
                ? plannedMeasurement.reqCount
                : matchingResultsInPeriod.length;
        actualCount += maxIntervalCount;
      }
    }

    return expectedCount == 0
        ? null
        : (actualCount / expectedCount * 100).round();
  }

  static int getProgressFromEvaluationItems(
    List<FulfillmentEvaluationItem> items,
  ) {
    if (items.isEmpty) return 0;

    int allActualMeasurementCount = items.fold(
      0,
      (sum, current) =>
          sum +
          (current.actualMeasurementCount > current.requiredMeasurementCount
              ? current.requiredMeasurementCount
              : current.actualMeasurementCount),
    );
    int allRequiredMeasurementCount =
        items.fold(0, (sum, current) => sum + current.requiredMeasurementCount);

    return (allActualMeasurementCount / allRequiredMeasurementCount * 100)
        .round();
  }

  static List<UserEvaluationDay> getUserEvaluationDays(
    int year,
    int month,
    CalendarDay day,
    List<UserAccount> userAccounts,
  ) {
    CalendarDbProvider calendarDbProvider = getIt<CalendarDbProvider>();
    PendingResultsDbProvider pendingResultsDbProvider =
        getIt<PendingResultsDbProvider>();
    List<UserEvaluationDay> userEvDays = [];

    for (final userAccount in userAccounts) {
      final List<Measurement>? offlineResults =
          pendingResultsDbProvider.getPerUser(userAccount.user.muid);

      final List<CarePlanSingleDayEvaluation> carePlanFulfillments = [];

      for (final carePlan in userAccount.carePlans!) {
        final List<PlannedMeasurement> plannedMeasurements =
            Calendar.getMeasurementOfDay(
          carePlans: [carePlan],
          dayDt: day.startDt,
        );

        final evItems = calendarDbProvider
                .get(
                  carePlan.id,
                  year,
                  month,
                )
                ?.items
                .where(
                  (evItem) =>
                      evItem.start.isSameDate(day.startDt) ||
                      (evItem.start.isAfter(day.startDt) &&
                          evItem.start.isBefore(day.endDt)),
                )
                .toList() ??
            [];

        /*
        debugPrint(
          'user ${userAccount.user.fullName}, plan ${carePlan.id}, ev items ${evItems.length} in day: ${day.startDt.toRegularDate()}',
        );
        */

        final carePlanSingleEvaluation = CarePlanSingleDayEvaluation(
          carePlan,
          evItems,
          plannedMeasurements,
          offlineResults,
        );

/*
        debugPrint(
          '${day.startDt.toRegularDate()} ${carePlan.activity.measurementType.name} measurements : ${carePlanSingleEvaluation.getActualCount()} / ${carePlanSingleEvaluation.getReqCount()}',
        );
        */

        carePlanFulfillments.add(carePlanSingleEvaluation);
      }

      if (carePlanFulfillments.isNotEmpty) {
        userEvDays.add(
          UserEvaluationDay(
            carePlanFulfillments,
            day.startDt,
            userAccount.user.fullName,
            day.dayPeriod,
          ),
        );
      }
    }

    return userEvDays;
  }
}
