import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'calendar_service_bloc_event.freezed.dart';

@freezed
class CalendarServiceBlocEvent with _$CalendarServiceBlocEvent {
  const factory CalendarServiceBlocEvent.init(
    CalendarMonth calendarMonth,
  ) = _Init;
}
