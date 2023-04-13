import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'calendar_fulfillment_service_bloc_event.freezed.dart';

@freezed
class CalendarFulfillmentServiceBlocEvent
    with _$CalendarFulfillmentServiceBlocEvent {
  const factory CalendarFulfillmentServiceBlocEvent.init(
    CalendarMonth month,
    List<CarePlan> carePlans,
  ) = _Init;

  const factory CalendarFulfillmentServiceBlocEvent.onDaySelected(
    DateTime selectedDayDt,
  ) = _OnDaySelected;

  const factory CalendarFulfillmentServiceBlocEvent.loadMonthFulfillments(
    CalendarMonth month,
    List<CarePlan> carePlans,
  ) = _LoadFulfillments;
}
