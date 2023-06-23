import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'calendar_footer_event.freezed.dart';

@freezed
class CalendarFooterEvent with _$CalendarFooterEvent {
  const factory CalendarFooterEvent.selectDay(CalendarDay? calendarDay) =
      _SelectDay;
}
