import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_int_value.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/source_device_info.dart';
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

  List<Measurement>? getAll() {
    if (box.isNotEmpty) {
      return box.values.toList();
    }
    return null;
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
      manualMeasurement.measurementDateTime!.toIso8601String(),
      manualMeasurement,
    );
    return manualMeasurement;
  }

  Future<Measurement> remove(
    final Measurement manualMeasurement,
  ) async {
    await box.delete(manualMeasurement.measurementDateTime!.toIso8601String());
    return manualMeasurement;
  }
}
