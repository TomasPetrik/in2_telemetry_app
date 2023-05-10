import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_event.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_state.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';

@injectable
class ResultsBloc extends Bloc<ResultsBlocEvent, ResultsBlocState> {
  late final List<MeasurementResult> _offlineResults;
  late final List<CarePlan> _allCarePlans;

  ResultsBloc() : super(ResultsBlocState()) {
    on<ResultsBlocEvent>((event, emit) async {
      event.when(
        init: (
          final ResultsWhenPeriod whenPeriod,
          final List<CarePlan> carePlans,
          final List<MeasurementResult> allServerResults,
          final List<Measurement>? pendingResults,
        ) async {
          _allCarePlans = carePlans;

          _offlineResults = MeasurementHelper.getOffilneResultsConverted(
            pendingResults ?? [],
            null,
            null,
          );

          final Map<ResultsWhenPeriod, int?> plansEvaluationPerPeriod =
              ResultsHelper.getPeriodFultillments(
            _allCarePlans,
            _offlineResults,
          );

          final results = carePlans.isEmpty
              ? null
              : ResultsHelper.getResultsByWhenPeriod(
                  carePlans: carePlans,
                  whenPeriod: whenPeriod,
                  allServerResults: allServerResults,
                  allOfflineResults: _offlineResults,
                  measurementType: null,
                );

          emit(
            ResultsBlocState(
              currentCarePlans: carePlans,
              selectedWhenPeriod: whenPeriod,
              uncategorizedResults: allServerResults,
              results: results,
              plansEvaluationPerPeriod: plansEvaluationPerPeriod,
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

          final results = ResultsHelper.getResultsByWhenPeriod(
            carePlans: carePlans,
            whenPeriod: state.selectedWhenPeriod!,
            allServerResults: state.uncategorizedResults!,
            allOfflineResults: _offlineResults,
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
          final results = ResultsHelper.getResultsByWhenPeriod(
            carePlans: state.currentCarePlans!,
            whenPeriod: whenPeriod,
            allServerResults: state.uncategorizedResults!,
            allOfflineResults: _offlineResults,
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
