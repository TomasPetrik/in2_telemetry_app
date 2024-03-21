import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/tables/measurements.dart';

part 'measurements_dao.drift.dart';

@DriftAccessor(tables: [Measurements])
class MeasurementsDao extends DatabaseAccessor<AppDatabase> with _$MeasurementsDaoMixin {
  MeasurementsDao(AppDatabase db) : super(db);

  Future<int> save(MeasurementsCompanion measurement) async {
    return await into(measurements).insert(
      measurement,
      onConflict: DoUpdate(
        (old) => measurement,
        target: [measurements.id, measurements.userId, measurements.measurementType, measurements.measuredAt],
      ),
    );
  }

  Future<List<Measurement>> getByUser(
    int userId,
    MeasurementType? ofType,
    DateTime? from,
    DateTime? to,
    bool? isUploaded,
  ) async {
    final query = select(measurements)
      ..where((x) => x.userId.equals(userId))
      ..orderBy([(measurement) => OrderingTerm(expression: measurement.measuredAt, mode: OrderingMode.asc)]);

    if (ofType != null) {
      query.where((x) => x.measurementType.equalsValue(ofType));
    }

    if (from != null) {
      query.where((x) => x.measuredAt.isBiggerOrEqualValue(from));
    }

    if (to != null) {
      query.where((x) => x.measuredAt.isBiggerOrEqualValue(to));
    }

    if (isUploaded != null) {
      query.where((x) => x.isUploaded.equals(isUploaded));
    }

    return await query.get();
  }

  /// Applies the given [changes] to all measurements of a given user.
  /// Primarily used for marking measurements as uploaded.
  Future<void> updateAllUserMeasurements(int userId, MeasurementsCompanion changes) async {
    await (update(measurements)..where((x) => x.userId.equals(userId))).write(changes);
  }

  Future<DateTime?> getUserEarliestMeasurementTime(int userId) async {
    final result = await (selectOnly(measurements)
          ..where(measurements.userId.equals(userId))
          ..orderBy([OrderingTerm(expression: measurements.measuredAt, mode: OrderingMode.asc)])
          ..addColumns([measurements.measuredAt])
          ..limit(1))
        .map((row) => row.read(measurements.measuredAt))
        .getSingleOrNull();

    return result;
  }
}
