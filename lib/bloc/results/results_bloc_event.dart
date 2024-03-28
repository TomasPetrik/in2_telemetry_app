import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';

part 'results_bloc_event.freezed.dart';

@freezed
class ResultsBlocEvent with _$ResultsBlocEvent {
  const factory ResultsBlocEvent.init({
    required final ResultsWhenPeriod whenPeriod,
  }) = _Init;
  const factory ResultsBlocEvent.whenPeriodChange(
    ResultsWhenPeriod whenPeriod,
  ) = _ChangeWhenPeriod;
  const factory ResultsBlocEvent.currentPlansChange(
    MeasurementType? measurementType,
  ) = _ChangeCurrentPlans;
}
