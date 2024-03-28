import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_event.dart';
import 'package:scalesoft_app/bloc/results/results_bloc_state.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/data/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';

@injectable
class ResultsBloc extends Bloc<ResultsBlocEvent, ResultsBlocState> {
  late final List<Measurement> _allMeasurements;
  late final List<CarePlan> _allCarePlans;

  final Session _session;
  final CarePlanDbProvider _carePlanDbProvider;
  final MeasurementsDbProvider _measurementsDbProvider;

  ResultsBloc(this._session, this._carePlanDbProvider, this._measurementsDbProvider) : super(ResultsBlocState()) {
    on<ResultsBlocEvent>((event, emit) async {
      event.when(
        init: (
          final ResultsWhenPeriod whenPeriod,
        ) async {
          final sessionAccounts = await _session.getSessionAccounts();

          final List<CarePlan> activeCarePlans = [];
          final List<Measurement> allMeasurements = [];

          final endOfToday = DateTime.now().endOfDay;

          for (final user in sessionAccounts) {
            final plans = await _carePlanDbProvider.getByUser(user.id);
            final activePlans = plans.where(
              (x) => x.versions
                  .any((version) => version.scheduledEnd == null || version.scheduledEnd!.isAfter(endOfToday)),
            );
            activeCarePlans.addAll(activePlans);

            final measurements = await _measurementsDbProvider.getByUser(user.id);
            allMeasurements.addAll(measurements);
          }

          _allMeasurements = allMeasurements;

          _allCarePlans = activeCarePlans;

          final Map<ResultsWhenPeriod, int?> plansEvaluationPerPeriod = ResultsHelper.getPeriodFulfillments(
            _allCarePlans,
            allMeasurements,
          );

          final results = ResultsHelper.getResultsByWhenPeriod(
            carePlans: activeCarePlans,
            whenPeriod: whenPeriod,
            allOfflineResults: allMeasurements,
            measurementType: null,
            users: sessionAccounts,
          );

          final allMeasurementTypes = results.map((x) => x.measurementType).toSet();

          emit(
            ResultsBlocState(
              currentCarePlans: activeCarePlans,
              selectedWhenPeriod: whenPeriod,
              results: results,
              allMeasurementTypes: allMeasurementTypes,
              plansEvaluationPerPeriod: plansEvaluationPerPeriod,
              sessionUsers: sessionAccounts,
            ),
          );
        },
        currentPlansChange: (final measurementType) {
          final carePlans = measurementType == null
              ? _allCarePlans
              : _allCarePlans
                  .where(
                    (carePlan) => carePlan.activity.measurementType == measurementType,
                  )
                  .toList();

          final results = ResultsHelper.getResultsByWhenPeriod(
            carePlans: carePlans,
            whenPeriod: state.selectedWhenPeriod!,
            allOfflineResults: _allMeasurements,
            measurementType: measurementType,
            users: state.sessionUsers ?? [],
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
            allOfflineResults: _allMeasurements,
            measurementType: state.measurementType,
            users: state.sessionUsers ?? [],
          );

          final allMeasurementTypes = results.map((x) => x.measurementType).toSet();

          emit(
            state.copyWith(
              selectedWhenPeriod: whenPeriod,
              allMeasurementTypes: allMeasurementTypes,
              results: results,
            ),
          );
        },
      );
    });
  }
}
