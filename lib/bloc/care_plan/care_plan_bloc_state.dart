import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

part 'care_plan_bloc_state.freezed.dart';

@freezed
class CarePlanBlocState with _$CarePlanBlocState {
  const CarePlanBlocState._();

  factory CarePlanBlocState({
    PlanWhenPeriod? selectedWhenPeriod,
    List<CarePlan>? currentCarePlans,
    PlannedMeasurement? nextMeasurement,
    List<PlannedMeasurement>? upcomingMeasurements,
    List<PlannedMeasurement>? allTodayMeasurements,
    List<MeasurementResult>? results,
    MeasurementType? measurementType,
    Map<PlanWhenPeriod, int>? allMeasurementCountsPerPeriod,
  }) = _CarePlanBlocState;
}
