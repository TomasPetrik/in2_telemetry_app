import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/time_settings/when_code_contract.dart';

part 'evaluation_interval_model.freezed.dart';

@freezed
class EvaluationIntervalModel with _$EvaluationIntervalModel {
  factory EvaluationIntervalModel(
    DateTime start,
    DateTime end,
    int frequency, {
    WhenCodeContract? whenCode,
  }) = _EvaluationIntervalModel;
}
