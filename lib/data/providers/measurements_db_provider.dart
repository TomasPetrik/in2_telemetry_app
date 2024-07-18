import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/enums/overall_health_state.dart';
import 'package:scalesoft_app/data/entities/enums/shortness_of_breath_level.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement/blood_pressure_value.dart';
import 'package:scalesoft_app/mapper/measurement_type_mapper.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';

@injectable
class MeasurementsDbProvider {
  final AppDatabase _database;
  final MeasurementTypeMapper _measurementTypeMapper;

  MeasurementsDbProvider(this._database, this._measurementTypeMapper);

  Future<void> saveAll(Iterable<MeasurementDataContract> measurements, int userId) async {
    for (final measurement in measurements) {
      MeasurementType measurementType = _measurementTypeMapper.convert(measurement.measurementType);

      final companion = switch (measurementType) {
        MeasurementType.temperature => MeasurementsCompanion.insert(
            userId: userId,
            measuredAt: measurement.measurementDateTime.toUtc(),
            measurementType: measurementType,
            temperature: Value(measurement.value),
          ),
        MeasurementType.bloodPressure => MeasurementsCompanion.insert(
            userId: userId,
            measuredAt: measurement.measurementDateTime.toUtc(),
            measurementType: measurementType,
            bloodPressure: Value(
              BloodPressureValue(
                systolic: measurement.composedValue?.firstValue?.round(),
                diastolic: measurement.composedValue?.secondValue?.round(),
              ),
            ),
          ),
        MeasurementType.oxygenSaturation => MeasurementsCompanion.insert(
            userId: userId,
            measuredAt: measurement.measurementDateTime.toUtc(),
            measurementType: measurementType,
            oxygenSaturation: Value(measurement.value?.round()),
          ),
        MeasurementType.steps ||
        MeasurementType.globalPosition ||
        MeasurementType.battery ||
        MeasurementType.ews =>
          null,
        MeasurementType.heartRate => MeasurementsCompanion.insert(
            userId: userId,
            measuredAt: measurement.measurementDateTime.toUtc(),
            measurementType: measurementType,
            heartRate: Value(measurement.value?.round()),
          ),
        MeasurementType.respiratoryRate => MeasurementsCompanion.insert(
            userId: userId,
            measuredAt: measurement.measurementDateTime.toUtc(),
            measurementType: measurementType,
            respiratoryRate: Value(measurement.value?.round()),
          ),
        MeasurementType.shortnessOfBreath => MeasurementsCompanion.insert(
            userId: userId,
            measuredAt: measurement.measurementDateTime.toUtc(),
            measurementType: measurementType,
            shortnessOfBreath: Value(ShortnessOfBreathLevel.fromValue(measurement.value)),
          ),
        MeasurementType.overallHealth => MeasurementsCompanion.insert(
            userId: userId,
            measuredAt: measurement.measurementDateTime.toUtc(),
            measurementType: measurementType,
            overallHealth: Value(OverallHealthState.fromValue(measurement.value)),
          ),
      };

      if (companion == null) {
        continue;
      }
      await save(companion);
    }
  }

  Future<int> saveModel(MeasurementCreateModel model) async {
    final companion = MeasurementsCompanion.insert(
      userId: model.userId,
      measuredAt: model.measuredAt.toUtc(),
      measurementType: model.measurementType,
      deviceId: Value(model.deviceId),
      temperature: Value(model.temperature),
      bloodPressure: Value(model.bloodPressure),
      heartRate: Value(model.heartRate),
      oxygenSaturation: Value(model.oxygenSaturation),
      respiratoryRate: Value(model.respiratoryRate),
      shortnessOfBreath: Value(model.shortnessOfBreath),
      overallHealth: Value(model.overallHealth),
      batteryPercentage: Value(model.batteryPercentage),
      isUploaded: const Value(false),
    );

    return await save(companion);
  }

  Future<int> save(MeasurementsCompanion measurement) async {
    return await _database.measurementsDao.save(measurement);
  }

  Future<List<Measurement>> getByUser(
    int userId, {
    MeasurementType? ofType,
    DateTime? from,
    DateTime? to,
    bool? isUploaded,
  }) async {
    return await _database.measurementsDao.getByUser(userId, ofType, from, to, isUploaded);
  }

  Future<List<Measurement>> getByUsers(
    Iterable<int> userIds, {
    MeasurementType? ofType,
    DateTime? from,
    DateTime? to,
    bool? isUploaded,
  }) async {
    return await _database.measurementsDao.getByUsers(userIds, ofType, from, to, isUploaded);
  }

  Future<void> removeOfflineMeasurement(DateTime measurementTime, MeasurementType measurementType) async {
    return await _database.measurementsDao.removeOfflineMeasurement(measurementTime, measurementType);
  }

  Future<void> updateUserMeasurements(int userId, MeasurementsCompanion changes) async {
    return await _database.measurementsDao.updateAllUserMeasurements(userId, changes);
  }
}
