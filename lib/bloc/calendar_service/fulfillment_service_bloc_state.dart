import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'fulfillment_service_bloc_state.freezed.dart';

@freezed
class FulfillmentServiceBlocState with _$FulfillmentServiceBlocState {
  const factory FulfillmentServiceBlocState({
    CalendarMonth? month,
    DateTime? selectedDayDt,
    bool? loading,
  }) = _CalendarServiceBlocState;
}
