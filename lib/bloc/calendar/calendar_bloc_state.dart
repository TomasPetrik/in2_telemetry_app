import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
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
    required bool updateOnlyHeader,
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
    @Default(false)
    bool wasResolved,
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
    required CalendarDayPeriod dayPeriod,
    bool? wasCheckedForEvaluation,
    int? carePlansEvaluation,
    List<PlannedMeasurement>? plannedMeasurements,
    List<UserModel>? userAccounts,
    List<MeasurementResultViewModel>? measurementResults,
    @Default(false)
    bool isSelected,
  }) = _CalendarDay;

  //filter out measurements which haven't been finished in this day
  //so there should be evaluation of measurements completed within specific day
  int getReqCount() {
    if (plannedMeasurements == null) {
      return 0;
    }

    return plannedMeasurements!.map((x) => x.reqCount).sum;
  }

  int getActualCount() {
    if (plannedMeasurements == null) {
      return 0;
    }

    return plannedMeasurements!.map((x) => x.currentCount! > x.reqCount? x.reqCount:x.currentCount!).sum;
  }

  int get evaluationPercentage => getActualCount() == 0
      ? 0
      : ((getActualCount() / getReqCount()) * 100).toInt();
}

@freezed
class UserEvaluationDay with _$UserEvaluationDay {
  UserEvaluationDay._();

  factory UserEvaluationDay(
    List<SingleDayMeasurementsOfExactType> carePlanFulfillments,
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

    //filter out measurements which were already completed
    //it can happened for regular measurements which started and was completed before todays midnight
    //or for periodical measurements which ending in future but was completed earlier
    futureMeasurements.removeWhere(
          (fMeasurement) =>
              CarePlanHelper.wasMeasured(fMeasurement.fulfillmentEvaluationItem),
    );

    return futureMeasurements;
  }

  List<MeasurementDataContract> getMeasurementResults() {
    final measurementResults =
        carePlanFulfillments.fold<List<MeasurementDataContract>>(
      [],
      (previousValue, carePlanFulfillments) =>
          [...previousValue, ...carePlanFulfillments.measurementResults],
    );
    return measurementResults;
  }
}

@Freezed(makeCollectionsUnmodifiable: false)
class SingleDayMeasurementsOfExactType with _$SingleDayMeasurementsOfExactType {
  SingleDayMeasurementsOfExactType._();

  factory SingleDayMeasurementsOfExactType(
    MeasurementType measurementType,
    List<PlannedMeasurement> plannedMeasurements,
    List<MeasurementContract> offlineResults,
    List<MeasurementDataContract> measurementResults,
  ) = _CarePlanFulfillment;

  int get evaluationPercentage => getActualCount() == 0
      ? 0
      : ((getActualCount() / getReqCount()) * 100).toInt();

  @override
  String toString() {
    return '${getActualCount()} / ${getReqCount()}';
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
    final actualCount = plannedMeasurements.fold<int>(
      0,
      (previousValue, plannedMeasurement) =>
          previousValue +
          (plannedMeasurement.currentCount! > plannedMeasurement.reqCount
              ? plannedMeasurement.reqCount
              : plannedMeasurement.currentCount!),
    );
    return actualCount;
  }
}

//this may be deleted, because from ui perspective needs to be decided period in the present
enum CalendarDayPeriod {
  past,
  today,
  future,
}
