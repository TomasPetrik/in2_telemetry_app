import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

part 'calendar_bloc_state.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class CalendarBlocState with _$CalendarBlocState {
  const factory CalendarBlocState({
    List<CalendarMonth>? months,
    int? currentMonth,
    int? currentYear,
    PageController? controller,
    required bool padEnds,
    bool? isCurrentMonth,
  }) = _CalendarBlocState;
}

@freezed
class CalendarMonth with _$CalendarMonth {
  const factory CalendarMonth({
    required int year,
    required int month,
    required DateTime monthStartDate,
    required Map<int, List<CalendarDay>> weekDays,
  }) = _CalendarMonth;
}

//TODO.. also save it to local db to fast preview or look last loaded data in offline mode
//when switch to different month, then save all days in dbs for offline usage
@unfreezed
class CalendarDay with _$CalendarDay {
  factory CalendarDay({
    required DateTime dt,
    required int dayIndex,
    required bool isDayOfCurrentMonth,
    //List<CarePlan> carePlans,
    //List<Fullfillments> evaluation,
    //List<Measurement>,
    //bool isToday,
    required CalendarDayPeriod dayPeriod,
    int? carePlansEvaluation,
    List<PlannedMeasurement>? plannedMeasurements,
  }) = _CalendarDay;
}

//this may be deleted, because from ui perspective needs to be decided period in the present
enum CalendarDayPeriod {
  past,
  today,
  future,
}
