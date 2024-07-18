import 'package:scalesoft_app/api/contracts/care_pan/aggregated_fulfillment_evaluation_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_version_contract.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';

class CarePlanCreateModel{
  final CarePlanContract plan;
  final bool wasChanged;
  final List<CarePlanVersionContract> versions;
  final AggregatedFulfillmentEvaluationContract fullPlanEvaluation;
  final List<FulfillmentEvaluationItem> evaluationItems;

  CarePlanCreateModel(this.plan, this.wasChanged, this.versions, this.fullPlanEvaluation, this.evaluationItems);
}