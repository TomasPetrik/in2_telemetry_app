import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'calendar_fulfillment_service_bloc_state.freezed.dart';

@freezed
class CalendarFulfillmentServiceBlocState
    with _$CalendarFulfillmentServiceBlocState {
  const factory CalendarFulfillmentServiceBlocState({
    CalendarMonth? month,
    DateTime? selectedDayDt,
    bool? loading,
  }) = _CalendarFulfillmentServiceBlocState;
}
