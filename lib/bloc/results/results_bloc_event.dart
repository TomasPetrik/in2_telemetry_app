import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';

part 'results_bloc_event.freezed.dart';

@freezed
class ResultsBlocEvent with _$ResultsBlocEvent {
  const factory ResultsBlocEvent.init({
    required final ResultsWhenPeriod whenPeriod,
    required final List<CarePlanContract> carePlans,
    required final List<MeasurementDataContract> allServerResults,
    required final List<Measurement> pendingResults,
  }) = _Init;
  const factory ResultsBlocEvent.whenPeriodChange(
    ResultsWhenPeriod whenPeriod,
  ) = _ChangeWhenPeriod;
  const factory ResultsBlocEvent.curentPlansChange(
    MeasurementTypeContract? measurementType,
  ) = _ChangeCurrentPlans;
}
