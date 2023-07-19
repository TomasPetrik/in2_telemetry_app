import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';

part 'daily_timing_model.freezed.dart';

@freezed
class TimeOfDayTimingModel with _$TimeOfDayTimingModel {
  factory TimeOfDayTimingModel({
    // required Duration timeOfDay,
    required Duration measurementWindowStart,
    required Duration measurementWindowEnd,
  }) = _TimeOfDayModel;
}