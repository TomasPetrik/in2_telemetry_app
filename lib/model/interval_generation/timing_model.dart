import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/time_unit.dart';
import 'package:scalesoft_app/data/entities/enums/week_day.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/model/interval_generation/time_of_day_timing_model.dart';

part 'timing_model.freezed.dart';

@freezed
class TimingModel with _$TimingModel {
  factory TimingModel(
    int? frequency,
    int? period,
    TimeUnit? periodUnit,
    List<WeekDay>? weekDays,
    List<TimeOfDayTimingModel>? timesOfDay,
    List<TimingDayWhen>? when,
) = _TimingModel;
}