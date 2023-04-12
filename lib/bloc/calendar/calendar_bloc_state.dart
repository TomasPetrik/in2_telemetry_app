import 'dart:math';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

part 'calendar_bloc_state.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class CalendarBlocState with _$CalendarBlocState {
  const factory CalendarBlocState({
    Key? key,
    List<CalendarMonth>? months,
    int? currentMonth,
    int? currentYear,
    DateTime? selectedDayDt,
    PageController? controller,
    required bool padEnds,
    required bool updateSelf,
    bool? isCurrentMonth,
  }) = _CalendarBlocState;
}

@unfreezed
class CalendarMonth with _$CalendarMonth {
  const CalendarMonth._();

  factory CalendarMonth({
    required int year,
    required int month,
    required DateTime monthStartDate,
    required DateTime monthEndDate,
    required Map<int, List<CalendarDay>> weekDays,
    bool? wasInit,
    bool? wasResolved,
  }) = _CalendarMonth;

  List<CalendarDay> getCalendarDays() {
    final calendarDays = weekDays.entries.fold<List<CalendarDay>>(
      [],
      (previousValue, week) => [...previousValue, ...week.value],
    );

    return calendarDays
        .where((calendarDay) => calendarDay.isDayOfCurrentMonth)
        .toList();
  }
}

@unfreezed
class CalendarDay with _$CalendarDay {
  const CalendarDay._();

  factory CalendarDay({
    required DateTime startDt,
    required DateTime endDt,
    required int dayIndex,
    required bool isDayOfCurrentMonth,
    //List<CarePlan> carePlans,
    //List<Fullfillments> evaluation,
    //List<Measurement>,
    //bool isToday,
    required CalendarDayPeriod dayPeriod,
    int? carePlansEvaluation,
    List<PlannedMeasurement>? plannedMeasurements,
    List<UserAccount>? userAccounts,
    List<UserEvaluationDay>? usersEvaluationsDay,
    bool? isSelected,
  }) = _CalendarDay;

  int get reqCount =>
      usersEvaluationsDay?.fold(
        0,
        (previousValue, usersEvaluatiosDay) =>
            (previousValue ?? 0) + usersEvaluatiosDay.reqCount,
      ) ??
      0;

  int get actualCount =>
      usersEvaluationsDay?.fold(
        0,
        (previousValue, usersEvaluatiosDay) =>
            (previousValue ?? 0) + usersEvaluatiosDay.actualCount,
      ) ??
      0;

  int get evaluationPercentage =>
      actualCount == 0 ? 0 : ((actualCount / reqCount) * 100).toInt();
}

@freezed
class UserEvaluationDay with _$UserEvaluationDay {
  UserEvaluationDay._();

  factory UserEvaluationDay(
    List<CarePlanSingleDayEvaluation> carePlanFulfillments,
    DateTime dt,
    String userName,
    CalendarDayPeriod calendarDayPeriod,
  ) = _UserEvaluationDay;

  List<PlannedMeasurement> getFutureMeasurements() {
    final futureMeasurements =
        carePlanFulfillments.fold<List<PlannedMeasurement>>(
      [],
      (previousValue, carePlanFulfillments) =>
          [...previousValue, ...carePlanFulfillments.plannedMeasurements],
    );
    return futureMeasurements;
  }

  List<HistoricMeasurement> getHistoricMeasurements() {
    final completedMeasurements =
        carePlanFulfillments.fold<List<HistoricMeasurement>>(
      [],
      (previousValue, carePlanFulfillments) =>
          [...previousValue, ...carePlanFulfillments.getHistoricMeasurements()],
    );
    return completedMeasurements;
  }

  int get evaluationPercentage =>
      actualCount == 0 ? 0 : ((actualCount / reqCount) * 100).toInt();

  int get reqCount => carePlanFulfillments.fold(
        0,
        (previousValue, carePlanFulfillment) =>
            previousValue + carePlanFulfillment.getReqCount(),
      );

  int get actualCount => carePlanFulfillments.fold(
        0,
        (previousValue, carePlanFulfillment) =>
            previousValue + carePlanFulfillment.getActualCount(),
      );
}

@freezed
class CarePlanSingleDayEvaluation with _$CarePlanSingleDayEvaluation {
  CarePlanSingleDayEvaluation._();

  factory CarePlanSingleDayEvaluation(
    CarePlan carePlan,
    List<FulfillmentEvaluationItem> evItems,
    List<PlannedMeasurement> plannedMeasurements,
    List<Measurement>? offlineResults,
  ) = _CarePlanFulfillment;

  int get evaluationPercentage => getActualCount() == 0
      ? 0
      : ((getActualCount() / getReqCount()) * 100).toInt();

  @override
  String toString() {
    return '${getActualCount()} / ${getReqCount()}';
  }

  List<HistoricMeasurement> getHistoricMeasurements() {
    List<HistoricMeasurement> historicMeasrements = [];
    for (final plannedMeasurement in plannedMeasurements) {
      DateTime? measuredAt;

      //1. try check server results
      final measurementTimes = evItems.fold<List<DateTime>>(
        [],
        (allTimes, evItem) => [...allTimes, ...evItem.actualMeasurementTimes],
      );

      final matchedTimes = measurementTimes
          .where(
            (mTime) =>
                (mTime == plannedMeasurement.whenStart ||
                    mTime.isAfter(plannedMeasurement.whenStart)) &&
                (mTime == plannedMeasurement.whenEnd ||
                    mTime.isBefore(plannedMeasurement.whenEnd)),
          )
          .toList();

      int reqMeasurementCount = plannedMeasurement.reqCount;
      int actualMeasurementCount = matchedTimes.length;

      if (matchedTimes.isNotEmpty) {
        measuredAt =
            matchedTimes[min(reqMeasurementCount - 1, matchedTimes.length - 1)];
      }

      //2. check if offline results matching datetime when measurement wasn't fulfilled completely
      if (actualMeasurementCount < reqMeasurementCount) {
        final carePlanOfflineResults = offlineResults?.where(
          (measurement) =>
              measurement.measurementType ==
                  plannedMeasurement.carePlan.activity.measurementType &&
              measurement.measurementDateTime
                      ?.isBefore(plannedMeasurement.whenEnd) ==
                  true &&
              measurement.measurementDateTime
                      ?.isAfter(plannedMeasurement.whenStart) ==
                  true,
        );

        if (carePlanOfflineResults != null) {
          for (final offlineResult in carePlanOfflineResults) {
            if (actualMeasurementCount < reqMeasurementCount) {
              actualMeasurementCount += 1;
              measuredAt = offlineResult.measurementDateTime;
            }
          }
        }
      }

      historicMeasrements.add(
        HistoricMeasurement(
          userId: plannedMeasurement.userId,
          whenStart: plannedMeasurement.whenStart,
          whenEnd: plannedMeasurement.whenEnd,
          measuredAt: measuredAt,
          carePlan: plannedMeasurement.carePlan,
          reqCount: reqMeasurementCount,
          actualCount: actualMeasurementCount,
          wasMeasured: actualMeasurementCount >= reqMeasurementCount,
          whenCode: plannedMeasurement.whenCode,
        ),
      );
    }
    return historicMeasrements;
  }

  int getReqCount() {
    final reqCount = plannedMeasurements.fold<int>(
      0,
      (previousValue, plannedMeasurement) =>
          previousValue + plannedMeasurement.reqCount,
    );
    return reqCount;
  }

  int getActualCount() {
    int allActualMeasurementCount = 0;
    for (final plannedMeasurement in plannedMeasurements) {
      //1. try check server results

      final measurementTimes = evItems.fold<List<DateTime>>(
        [],
        (allTimes, evItem) => [...allTimes, ...evItem.actualMeasurementTimes],
      );

      final matchedTimes = measurementTimes
          .where(
            (mTime) =>
                (mTime == plannedMeasurement.whenStart ||
                    mTime.isAfter(plannedMeasurement.whenStart)) &&
                (mTime == plannedMeasurement.whenEnd ||
                    mTime.isBefore(plannedMeasurement.whenEnd)),
          )
          .toList();

      int reqMeasurementCount = plannedMeasurement.reqCount;
      int actualMeasurementCount = matchedTimes.length;

      //2. check if offline results matching datetime when measurement wasn't fulfilled completely
      if (actualMeasurementCount < reqMeasurementCount) {
        final carePlanOfflineResults = offlineResults?.where(
          (measurement) =>
              measurement.measurementType ==
                  plannedMeasurement.carePlan.activity.measurementType &&
              measurement.measurementDateTime
                      ?.isBefore(plannedMeasurement.whenEnd) ==
                  true &&
              measurement.measurementDateTime
                      ?.isAfter(plannedMeasurement.whenStart) ==
                  true,
        );
        if (carePlanOfflineResults?.isNotEmpty == true) {
          actualMeasurementCount += carePlanOfflineResults!.length;
        }
      }

      if (actualMeasurementCount > reqMeasurementCount) {
        actualMeasurementCount = reqMeasurementCount;
      }

      allActualMeasurementCount += actualMeasurementCount;
    }
    return allActualMeasurementCount;
  }
}

//this may be deleted, because from ui perspective needs to be decided period in the present
enum CalendarDayPeriod {
  past,
  today,
  future,
}
