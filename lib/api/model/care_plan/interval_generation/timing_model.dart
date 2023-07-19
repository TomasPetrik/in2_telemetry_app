import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/daily_timing_model.dart';
import 'package:scalesoft_app/api/model/care_plan/interval_generation/when_model.dart';

part 'timing_model.freezed.dart';

@freezed
class TimingModel with _$TimingModel {
  factory TimingModel(
    int? frequency,
    int? period,
    TimeUnit? periodUnit,
    List<WeekDay>? weekDays,
    List<TimeOfDayTimingModel>? timesOfDay,
    List<WhenModel>? when,
) = _TimingModel;
}