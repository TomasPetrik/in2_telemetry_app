import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';

part 'results_bloc_state.freezed.dart';

@freezed
class ResultsBlocState with _$ResultsBlocState {
  const ResultsBlocState._();

  factory ResultsBlocState({
    ResultsWhenPeriod? selectedWhenPeriod,
    List<CarePlan>? currentCarePlans,
    List<MeasurementResult>? uncategorizedResults,
    List<MeasurementResult>? results,
    MeasurementType? measurementType,
    Set<MeasurementType>? allMeasurementTypes,
    Map<ResultsWhenPeriod, int?>? plansEvaluationPerPeriod,
  }) = _ResultsBlocState;
}
