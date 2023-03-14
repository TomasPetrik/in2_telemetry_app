import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_bloc_event.freezed.dart';

@freezed
class CalendarBlocEvent with _$CalendarBlocEvent {
  const factory CalendarBlocEvent.init(
    BuildContext context,
    DateTime fromDate,
    DateTime toDate,
  ) = _Init;
  const factory CalendarBlocEvent.resetToToday() = _ResetToToday;
  const factory CalendarBlocEvent.onPageChanged(int newPage) = _OnPageChanged;
}
