import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'aggregated_fulfillment_evaluation_contract.g.dart';

@JsonSerializable()
class AggregatedFulfillmentEvaluationContract {
  @JsonKey(fromJson: toLocalDate)
  final DateTime start;

  @JsonKey(fromJson: toLocalDate)
  final DateTime end;

  final int requiredMeasurementCount;
  final int totalMeasurementCount;
  final int measurementInPlanCount;

  AggregatedFulfillmentEvaluationContract(
    this.start,
    this.end,
    this.requiredMeasurementCount,
    this.totalMeasurementCount,
    this.measurementInPlanCount,
  );

  factory AggregatedFulfillmentEvaluationContract.fromJson(Map<String, dynamic> json) =>
      _$AggregatedFulfillmentEvaluationContractFromJson(json);

  Map<String, dynamic> toJson() => _$AggregatedFulfillmentEvaluationContractToJson(this);

  @override
  String toString() => toJson().toString();
}
