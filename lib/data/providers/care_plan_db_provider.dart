import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_author.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_version.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_aggregated.dart';
import 'package:scalesoft_app/mapper/care_plan_activity_mapper.dart';
import 'package:scalesoft_app/mapper/care_plan_version_mapper.dart';
import 'package:scalesoft_app/model/care_plan_create_model.dart';

@injectable
class CarePlanDbProvider {
  final AppDatabase _database;
  final CarePlanVersionMapper _carePlanVersionMapper;
  final CarePlanActivityMapper _carePlanActivityMapper;

  CarePlanDbProvider(this._database, this._carePlanVersionMapper, this._carePlanActivityMapper);

  Future<void> replaceUserCarePlans(int userId, List<CarePlanCreateModel> newPlans) async {
    await _database.carePlansDao.removeUserPlans(userId);

    for (final plan in newPlans) {
      final author = CarePlanAuthor(plan.plan.author.muid, plan.plan.author.firstNames, plan.plan.author.lastNames);

      final fullPlanEvaluation = FulfillmentEvaluationAggregated(
        plan.fullPlanEvaluation.start,
        plan.fullPlanEvaluation.end,
        plan.fullPlanEvaluation.requiredMeasurementCount,
        plan.fullPlanEvaluation.totalMeasurementCount,
        plan.fullPlanEvaluation.measurementInPlanCount,
      );

      final List<CarePlanVersion> versions = _carePlanVersionMapper.convertList(plan.versions);
      final CarePlanActivity activity = _carePlanActivityMapper.convert(plan.plan.activity);

      final companion = CarePlansCompanion.insert(
        remoteId: plan.plan.id,
        targetUserId: userId,
        activity: activity,
        author: author,
        fullPlanEvaluation: fullPlanEvaluation,
        evaluationItems: plan.evaluationItems,
        versions: versions,
      );

      await _database.carePlansDao.save(companion);
    }
  }

  Future<void> resolveUpdatedCarePlan(int carePlanId) async {
    await _database.carePlansDao.updatePlan(carePlanId, const CarePlansCompanion(wasChanged: Value(false)));
  }

  Future<List<CarePlan>> getByUser(int userId) async {
    return await _database.carePlansDao.getByUser(userId);
  }

  Future<List<CarePlan>> getByUsers(Iterable<int> userIds) async {
    return await _database.carePlansDao.getByUsers(userIds);
  }

  Future<CarePlan?> get(int carePlanId) async {
    return await _database.carePlansDao.get(carePlanId);
  }

  Future<List<CarePlan>> getPlans(Iterable<int> ids) async {
    return await _database.carePlansDao.getPlans(ids);
  }
}
