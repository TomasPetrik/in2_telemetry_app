import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';

part 'chart_loader_bloc_event.freezed.dart';

@freezed
class ChartLoaderBlocEvent with _$ChartLoaderBlocEvent {
  const factory ChartLoaderBlocEvent.init(
    MeasurementTypeContract measurementType,
    UserAccount userAccount,
    CalendarMonth month,
  ) = _Init;

  const factory ChartLoaderBlocEvent.loadMonthMeaurements(
    MeasurementTypeContract measurementType,
    UserAccount userAccount,
    CalendarMonth month,
  ) = _LoadMonthMeaurements;
}
