import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_bloc_event.freezed.dart';

@freezed
class CalendarBlocEvent with _$CalendarBlocEvent {
  const factory CalendarBlocEvent.init(
    BuildContext context,
    DateTime? preSelectedDt,
    List<int> carePlansIds,
  ) = _Init;
  const factory CalendarBlocEvent.goOnDate(DateTime dateTime) = _GoOnDate;
  const factory CalendarBlocEvent.onPageChanged(int newPage) = _OnPageChanged;
  const factory CalendarBlocEvent.addExtraMonth() = _AddExtraMonth;
  const factory CalendarBlocEvent.onDaySelected(
    DateTime selectedDayDt,
    bool updateSelf,
  ) = _OnDaySelected;
  const factory CalendarBlocEvent.nullDefaultDay() = _NullDefaultDay;
}
