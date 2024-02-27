import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/daily_timing_model.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/timing_day_when.dart';

part 'timing_model.freezed.dart';

@freezed
class TimingModel with _$TimingModel {
  factory TimingModel(
    int? frequency,
    int? period,
    TimeUnitContract? periodUnit,
    List<WeekDayContract>? weekDays,
    List<TimeOfDayTimingModel>? timesOfDay,
    List<TimingDayWhen>? when,
) = _TimingModel;
}