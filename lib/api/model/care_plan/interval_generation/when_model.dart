import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';

part 'when_model.freezed.dart';

@freezed
class WhenModel with _$WhenModel {
  factory WhenModel({
    required WhenCode whenCode,
    required DailyTime start,
    required DailyTime end,
  }) = _WhenModel;
}