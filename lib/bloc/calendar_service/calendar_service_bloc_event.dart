import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'calendar_service_bloc_event.freezed.dart';

@freezed
class CalendarServiceBlocEvent with _$CalendarServiceBlocEvent {
  const factory CalendarServiceBlocEvent.init(
    CalendarMonth month,
    DateTime? selectedDayDt,
  ) = _Init;

  const factory CalendarServiceBlocEvent.onDaySelected(
    DateTime selectedDayDt,
  ) = _OnDaySelected;

  const factory CalendarServiceBlocEvent.loadMonthFulfillments(
    CalendarMonth month,
    List<CarePlan> carePlans,
  ) = _LoadFulfillments;
}
