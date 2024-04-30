import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';

part 'chart_loader_bloc_event.freezed.dart';

@freezed
class ChartLoaderBlocEvent with _$ChartLoaderBlocEvent {
  const factory ChartLoaderBlocEvent.init(
    MeasurementType measurementType,
    UserModel userAccount,
    CalendarMonth month,
  ) = _Init;
}
