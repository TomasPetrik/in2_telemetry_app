import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/measurement/composed_int_value.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/source_device_info.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class PendingResultsDbProvider extends BoxProvider<Measurement> {
  @override
  final String boxName = 'pendingResultsBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(MeasurementAdapter());
    Hive.registerAdapter(BloodPressureValueAdapter());
    Hive.registerAdapter(SourceDeviceInfoAdapter());
  }

  List<Measurement> getAll() {
    if (box.isNotEmpty) {
      return box.values.toList();
    }
    return [];
  }

  List<Measurement>? getPerUser(String userId) {
    if (box.isNotEmpty) {
      return box.values
          .where((measurement) => measurement.patientMuid == userId)
          .toList();
    }
    return null;
  }

  Measurement? getAt(final int index) {
    return box.getAt(index);
  }

  Future<Measurement> save(
    final Measurement manualMeasurement,
  ) async {
    await box.put(
      '${manualMeasurement.measurementDateTime!.millisecondsSinceEpoch}',
      manualMeasurement,
    );
    return manualMeasurement;
  }

  Future<Measurement> remove(
    final Measurement manualMeasurement,
  ) async {
    final measurementId =
        manualMeasurement.measurementDateTime!.millisecondsSinceEpoch;
    await box.delete('$measurementId');
    return manualMeasurement;
  }

  Future<void> removeByDateTime(
    final DateTime measurementDateTime,
  ) async {
    await box.delete('${measurementDateTime.millisecondsSinceEpoch}');
  }

  Future<void> removeUserResults(
    final String userId,
  ) async {
    final userMeasurements = getPerUser(userId);
    if (userMeasurements == null) return;
    for (final userMeasurement in userMeasurements) {
      await remove(userMeasurement);
    }
  }
}
