import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_event.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_state.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';

@singleton
class ResultsBloc extends Bloc<ResultsBlocEvent, ResultsBlocState> {
  final List<Measurement> _pendingResults = [];
  final List<CarePlan> _allCarePlans = [];

  ResultsBloc() : super(ResultsBlocState()) {
    on<ResultsBlocEvent>((event, emit) async {
      event.when(
        init: (
          final ResultsWhenPeriod whenPeriod,
          final List<CarePlan> carePlans,
          final List<MeasurementResult> uncategorizedResults,
          final List<Measurement>? pendingResults,
        ) async {
          _allCarePlans.clear();
          _allCarePlans.addAll(carePlans);
          _pendingResults.clear();
          _pendingResults.addAll(pendingResults ?? []);

          final results = carePlans.isEmpty
              ? null
              : ResultsHelper.getResults(
                  carePlans: carePlans,
                  whenPeriod: whenPeriod,
                  measurementResults: uncategorizedResults,
                  pendingResults: _pendingResults,
                  measurementType: null,
                );

          emit(
            ResultsBlocState(
              currentCarePlans: carePlans,
              selectedWhenPeriod: whenPeriod,
              uncategorizedResults: uncategorizedResults,
              results: results,
            ),
          );
        },
        curentPlansChange: (final measurementType) {
          final carePlans = measurementType == null
          ? _allCarePlans
          : _allCarePlans
              .where(
                (carePlan) =>
                    carePlan.activity.measurementType == measurementType,
              )
              .toList();

          final results = ResultsHelper.getResults(
            carePlans: carePlans,
            whenPeriod: state.selectedWhenPeriod!,
            measurementResults: state.uncategorizedResults!,
            pendingResults: _pendingResults,
            measurementType: measurementType,
          );

          emit(
            state.copyWith(
              currentCarePlans: carePlans,
              results: results,
              measurementType: measurementType,
            ),
          );
        },
        whenPeriodChange: (final whenPeriod) {
          final results = ResultsHelper.getResults(
            carePlans: state.currentCarePlans!,
            whenPeriod: whenPeriod,
            measurementResults: state.uncategorizedResults!,
            pendingResults: _pendingResults,
            measurementType: state.measurementType,
          );

          emit(
            state.copyWith(
              selectedWhenPeriod: whenPeriod,
              results: results,
            ),
          );
        },
      );
    });
  }
}
