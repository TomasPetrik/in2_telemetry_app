import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'calendar_fulfillment_service_bloc_event.freezed.dart';

@freezed
class CalendarFulfillmentServiceBlocEvent
    with _$CalendarFulfillmentServiceBlocEvent {
  const factory CalendarFulfillmentServiceBlocEvent.init(
    CalendarMonth month,
    List<int> carePlansIds,
  ) = _Init;

  const factory CalendarFulfillmentServiceBlocEvent.onDaySelected(
    DateTime selectedDayDt,
  ) = _OnDaySelected;

  const factory CalendarFulfillmentServiceBlocEvent.loadMonthFulfillments(
    CalendarMonth month,
    List<CarePlanContract> carePlans,
  ) = _LoadFulfillments;
}
