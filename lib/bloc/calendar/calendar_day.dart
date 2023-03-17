import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'calendar_day.freezed.dart';

@freezed
class CalendarFooterState with _$CalendarFooterState {
  factory CalendarFooterState({
    CalendarDay? selectedDay,
  }) = _CalendarFooterState;
}
