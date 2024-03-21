import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/tables/care_plans.dart';

part 'care_plans_dao.drift.dart';

@DriftAccessor(tables: [CarePlans])
class CarePlansDao extends DatabaseAccessor<AppDatabase> with _$CarePlansDaoMixin {
  CarePlansDao(AppDatabase db) : super(db);

  Future<void> updatePlan(int carePlanId, CarePlansCompanion changes) async {
    await (update(carePlans)..where((x) => x.id.equals(carePlanId))).write(changes);
  }

  Future<void> removeUserPlans(int userId) async {
    await (delete(carePlans)..where((x) => x.targetUserId.equals(userId))).go();
  }

  Future<int> save(CarePlansCompanion carePlan) async {
    return await into(carePlans).insert(
      carePlan,
      onConflict: DoUpdate((old) => carePlan, target: [carePlans.targetUserId, carePlans.remoteId]),
    );
  }

  Future<List<CarePlan>> getByUser(int userId) async {
    return await (select(carePlans)..where((x) => x.targetUserId.equals(userId))).get();
  }

  Future<CarePlan?> get(int id) async {
    return await (select(carePlans)..where((x) => x.id.equals(id))).getSingleOrNull();
  }
}
