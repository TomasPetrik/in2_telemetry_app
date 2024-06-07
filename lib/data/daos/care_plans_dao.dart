import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/tables/care_plans.dart';

part 'care_plans_dao.drift.dart';

@DriftAccessor(tables: [CarePlans])
class CarePlansDao extends DatabaseAccessor<AppDatabase> with _$CarePlansDaoMixin {
  CarePlansDao(super.db);

  Future<void> updatePlan(int carePlanId, CarePlansCompanion changes) async {
    await (update(carePlans)..where((x) => x.id.equals(carePlanId))).write(changes);
  }

  Future<void> removeUserPlans(int userId) async {
    await (delete(carePlans)..where((x) => x.targetUserId.equals(userId))).go();
  }

  Future<int> save(CarePlansCompanion carePlan) async {
    return await into(carePlans).insert(
      carePlan,
      onConflict: DoUpdate((old) => carePlan, target: []),
    );
  }

  Future<List<CarePlan>> getByUser(int userId) async {
    return await (select(carePlans)..where((x) => x.targetUserId.equals(userId))).get();
  }

  Future<CarePlan?> get(int id) async {
    return await (select(carePlans)..where((x) => x.id.equals(id))).getSingleOrNull();
  }

  Future<List<CarePlan>> getPlans(Iterable<int> ids) async {
    return await (select(carePlans)..where((x) => x.id.isIn(ids))).get();
  }

  Future<List<CarePlan>> getByUsers(Iterable<int> userIds) async {
    return await (select(carePlans)..where((x) => x.targetUserId.isIn(userIds))).get();
  }

  Future<List<CarePlan>> getChangedPlans(Iterable<int> userIds) async {
    return await (select(carePlans)
          ..where((x) => x.targetUserId.isIn(userIds))
          ..where((x) => x.wasChanged.equals(true)))
        .get();
  }
}
