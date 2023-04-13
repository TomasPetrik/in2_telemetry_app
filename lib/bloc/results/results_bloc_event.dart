import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';

part 'results_bloc_event.freezed.dart';

@freezed
class ResultsBlocEvent with _$ResultsBlocEvent {
  const factory ResultsBlocEvent.init({
    required final ResultsWhenPeriod whenPeriod,
    required final List<CarePlan> carePlans,
    required final List<MeasurementResult> uncategorizedResults,
    final List<Measurement>? pendingResults,
  }) = _Init;
  const factory ResultsBlocEvent.whenPeriodChange(
    ResultsWhenPeriod whenPeriod,
  ) = _ChangeWhenPeriod;
  const factory ResultsBlocEvent.curentPlansChange(
    MeasurementType? measurementType,
  ) = _ChangeCurrentPlans;
}
