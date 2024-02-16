import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/data/app_database.dart';

@singleton
class CarePlanRepository {
  final AppDatabase _database;

  CarePlanRepository(this._database);

  // Future<int> createPlan({String? targetUserMuid}) async {
  //   return await _database.into(_database.carePlans).insert(
  //         CarePlansCompanion.insert(
  //           targetUserMuid: Value(targetUserMuid),
  //           scheduledStart: DateTime.now(),
  //         ), onConflict: UpsertClause
  //       );
  // }
  //
  // Future<int> createPlanB(CarePlan plan) async{
  //   return await _database.into(_database.carePlans).insert(
  //     plan,
  //   );
  // }
  //
  // Future<List<CarePlan>> getPlans() async {
  //   return await _database.select(_database.carePlans).get();
  // }
}
