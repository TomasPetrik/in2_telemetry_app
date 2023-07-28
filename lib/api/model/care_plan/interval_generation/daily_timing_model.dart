import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_timing_model.freezed.dart';

@freezed
class TimeOfDayTimingModel with _$TimeOfDayTimingModel {
  factory TimeOfDayTimingModel({
    required Duration measurementWindowStart,
    required Duration measurementWindowEnd,
  }) = _TimeOfDayModel;
}
