import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'calendar_service_bloc_state.freezed.dart';

@freezed
class CalendarServiceBlocState with _$CalendarServiceBlocState {
  const factory CalendarServiceBlocState.init() = _Init;
  const factory CalendarServiceBlocState.popoulated(
    CalendarMonth month,
  ) = _Populated;
}
