import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

part 'care_plan_bloc_state.freezed.dart';

@freezed
class CarePlanBlocState with _$CarePlanBlocState {
  const CarePlanBlocState._();

  factory CarePlanBlocState({
    int? timestamp,
    PlanWhenPeriod? selectedWhenPeriod,
    List<CarePlan>? currentCarePlans,
    PlannedMeasurement? nextMeasurement,
    List<PlannedMeasurement>? upcomingMeasurements,
    List<PlannedMeasurement>? allTodayMeasurements,
    List<Measurement>? results,
    MeasurementType? measurementType,
    Map<PlanWhenPeriod, int>? allMeasurementCountsPerPeriod,
  }) = _CarePlanBlocState;
}
