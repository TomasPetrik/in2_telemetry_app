import 'package:hive_flutter/adapters.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class MeasurementsDbProvider extends BoxProvider<MeasurementResults> {
  @override
  final String boxName = 'MeasurementsBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(MeasurementResultsAdapter());
  }

  MeasurementResults? get(
    String userId,
    MeasurementType measurementType,
    int year,
    int month,
  ) {
    final measurements =
        box.get('$userId:${measurementType.name}:$year:$month');
    return measurements;
  }

  Future<void> put(
    String userId,
    MeasurementType measurementType,
    int year,
    int month,
    MeasurementResults measurementResults,
  ) async {
    await box.put(
      '$userId:${measurementType.name}:$year:$month',
      measurementResults,
    );
  }
}
