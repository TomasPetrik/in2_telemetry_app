import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';

@injectable
class MeasurementsDbProvider {
  final AppDatabase _database;

  MeasurementsDbProvider(this._database);

  // TODO
  // Future<int> save(MeasurementsCompanion measurement) async {}

  Future<List<Measurement>> getByUser(
    int userId, {
    MeasurementType? ofType,
    DateTime? from,
    DateTime? to,
    bool? isUploaded,
  }) async {
    return await _database.measurementsDao.getByUser(userId, ofType, from, to, isUploaded);
  }

// /// Applies the given [changes] to all measurements of a given user.
// /// Primarily used for marking measurements as uploaded.
// Future<void> updateAllUserMeasurements(int userId, MeasurementsCompanion changes) async {
//   await (update(measurements)..where((x) => x.userId.equals(userId))).write(changes);
// }
//
// Future<DateTime?> getUserEarliestMeasurementTime(int userId) async {
//   final result = await (selectOnly(measurements)
//     ..where(measurements.userId.equals(userId))
//     ..orderBy([OrderingTerm(expression: measurements.measuredAt, mode: OrderingMode.asc)])
//     ..addColumns([measurements.measuredAt])
//     ..limit(1))
//       .map((row) => row.read(measurements.measuredAt))
//       .getSingleOrNull();
//
//   return result;
// }
}
