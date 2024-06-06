import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/user_model.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';

part 'results_bloc_state.freezed.dart';

@freezed
class ResultsBlocState with _$ResultsBlocState {
  const ResultsBlocState._();

  factory ResultsBlocState({
    ResultsWhenPeriod? selectedWhenPeriod,
    List<CarePlan>? currentCarePlans,
    List<CarePlan>? allCarePlans,
    List<MeasurementResultViewModel>? results,
    MeasurementType? measurementType,
    Set<MeasurementType>? allMeasurementTypes,
    Map<ResultsWhenPeriod, int?>? plansEvaluationPerPeriod,
    List<UserModel>? sessionUsers,
    List<Measurement>? offlineResults,
  }) = _ResultsBlocState;
}
