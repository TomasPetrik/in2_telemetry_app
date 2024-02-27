import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';

part 'results_bloc_state.freezed.dart';

@freezed
class ResultsBlocState with _$ResultsBlocState {
  const ResultsBlocState._();

  factory ResultsBlocState({
    ResultsWhenPeriod? selectedWhenPeriod,
    List<CarePlanContract>? currentCarePlans,
    List<MeasurementDataContract>? uncategorizedResults,
    List<MeasurementDataContract>? results,
    MeasurementTypeContract? measurementType,
    Set<MeasurementTypeContract>? allMeasurementTypes,
    Map<ResultsWhenPeriod, int?>? plansEvaluationPerPeriod,
  }) = _ResultsBlocState;
}
