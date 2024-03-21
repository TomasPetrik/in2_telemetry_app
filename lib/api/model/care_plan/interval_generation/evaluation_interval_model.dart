import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/when_code.dart';

part 'evaluation_interval_model.freezed.dart';

@freezed
class EvaluationIntervalModel with _$EvaluationIntervalModel {
  factory EvaluationIntervalModel(
    DateTime start,
    DateTime end,
    int frequency, {
    WhenCode? whenCode,
  }) = _EvaluationIntervalModel;
}
