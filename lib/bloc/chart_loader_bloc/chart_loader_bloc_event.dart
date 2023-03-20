import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/model/user_account.dart';

part 'chart_loader_bloc_event.freezed.dart';

@freezed
class ChartLoaderBlocEvent with _$ChartLoaderBlocEvent {
  const factory ChartLoaderBlocEvent.init(
    MeasurementType measurementType,
    UserAccount userAccount,
    CalendarMonth month,
  ) = _Init;

  const factory ChartLoaderBlocEvent.loadMonthMeaurements(
    MeasurementType measurementType,
    UserAccount userAccount,
    CalendarMonth month,
  ) = _LoadMonthMeaurements;
}
