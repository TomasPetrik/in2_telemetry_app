import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_author.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_version.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_aggregated.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';
import 'package:scalesoft_app/data/tables/users.dart';

class CarePlans extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer()();

  IntColumn get targetUserId => integer().references(Users, #id, onDelete: KeyAction.cascade)();

  TextColumn get activity => text().map(const CarePlanActivityConverter())();

  TextColumn get author => text().map(const CarePlanAuthorConverter())();

  TextColumn get fullPlanEvaluation => text().map(const FulfillmentEvaluationAggregatedConverter())();

  TextColumn get evaluationItems => text().map(const FulfillmentEvaluationItemListConverter())();

  BoolColumn get wasChanged => boolean().withDefault(const Constant(false))();

  TextColumn get versions => text().map(CarePlanVersion.listConverter)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {targetUserId, remoteId},
  ];
}
