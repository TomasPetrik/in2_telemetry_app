import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_int_value.dart';
import 'package:scalesoft_app/api/dto/measurement/manual_measurement.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class PendingResultsDbProvider extends BoxProvider<ManualMeasurement> {
  @override
  final String boxName = 'pendingResultsBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(ManualMeasurementAdapter());
    Hive.registerAdapter(ComposedIntValueAdapter());
  }

  List<ManualMeasurement>? getAll() {
    if (box.isNotEmpty) {
      return box.values.toList();
    }
    return null;
  }

  ManualMeasurement? getAt(final int index) {
    return box.getAt(index);
  }

  Future<ManualMeasurement> save(
    final ManualMeasurement manualMeasurement,
  ) async {
    await box.put(
      manualMeasurement.measurementDateTime!.toIso8601String(),
      manualMeasurement,
    );
    return manualMeasurement;
  }

  Future<ManualMeasurement> remove(
    final ManualMeasurement manualMeasurement,
  ) async {
    await box.delete(manualMeasurement.measurementDateTime!.toIso8601String());
    return manualMeasurement;
  }
}
