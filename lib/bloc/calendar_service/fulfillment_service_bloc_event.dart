import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'fulfillment_service_bloc_event.freezed.dart';

@freezed
class FulfillmentServiceBlocEvent with _$FulfillmentServiceBlocEvent {
  const factory FulfillmentServiceBlocEvent.init(
    CalendarMonth month,
    List<CarePlan> carePlans,
  ) = _Init;

  const factory FulfillmentServiceBlocEvent.onDaySelected(
    DateTime selectedDayDt,
  ) = _OnDaySelected;

  const factory FulfillmentServiceBlocEvent.loadMonthFulfillments(
    CalendarMonth month,
    List<CarePlan> carePlans,
  ) = _LoadFulfillments;
}
