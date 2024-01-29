import 'package:hive_flutter/adapters.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class MeasurementsDbProvider extends BoxProvider<MeasurementResults> {

  @override
  @PostConstruct(preResolve: true)
  Future<void> init() async => super.init();
  
  @override
  final String boxName = 'MeasurementsBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(MeasurementResultsAdapter());
  }

  MeasurementResults? get(
    String userId,
    MeasurementTypeContract measurementType,
    int year,
    int month,
  ) {
    final measurements =
        box.get('$userId:${measurementType.name}:$year:$month');
    return measurements;
  }

  Future<void> put(
    String userId,
    MeasurementTypeContract measurementType,
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
