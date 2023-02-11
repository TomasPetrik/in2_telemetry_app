import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

@singleton
class CarePlanBloc extends Bloc<CarePlanBlocEvent, CarePlanBlocState> {
  final List<MeasurementResult> _uncategorizedResults = [];
  final List<Measurement> _pendingResults = [];

  CarePlanBloc() : super(CarePlanBlocState()) {
    on<CarePlanInitializeEvent>((event, emit) async {
      _uncategorizedResults.clear();
      _uncategorizedResults.addAll(event.uncategorizedResults);
      _pendingResults.clear();
      _pendingResults.addAll(event.pendingResults ?? []);

      final List<MeasurementResult> todayResults = MeasurementHelper.getResults(
        _uncategorizedResults,
        _pendingResults,
        ResultsWhenPeriod.today,
        null,
      );

      final nextMeasurement = event.carePlans.isEmpty
          ? null
          : Calendar.getNUpcomingMeasurements(
              carePlans: event.carePlans,
              reqCount: 1,
              measurementResults: todayResults,
            );

      final measurements = event.carePlans.isEmpty
          ? null
          : CarePlanHelper.getMeasurements(
              event.carePlans,
              event.whenPeriod,
              todayResults,
            );

      emit(
        CarePlanBlocState(
          currentCarePlans: event.carePlans,
          selectedWhenPeriod: event.whenPeriod,
          nextMeasurement: nextMeasurement?.first,
          measurements: measurements,
          results: todayResults,
          measurementType: null,
        ),
      );
    });

    on<TimePeriodChangeEvent>((event, emit) {
      final List<MeasurementResult> todayResults = MeasurementHelper.getResults(
        _uncategorizedResults,
        _pendingResults,
        ResultsWhenPeriod.today,
        state.measurementType,
      );

      final nextMeasurement = Calendar.getNUpcomingMeasurements(
        carePlans: state.currentCarePlans!,
        reqCount: 1,
        measurementResults: todayResults,
      );

      final measurements = CarePlanHelper.getMeasurements(
        state.currentCarePlans!,
        event.whenPeriod,
        todayResults,
      );

      emit(
        state.copyWith(
          selectedWhenPeriod: event.whenPeriod,
          nextMeasurement: nextMeasurement.first,
          measurements: measurements,
        ),
      );
    });

    on<CurrentPlansChangeEvent>((event, emit) {
      final List<MeasurementResult> todayResults = MeasurementHelper.getResults(
        _uncategorizedResults,
        _pendingResults,
        ResultsWhenPeriod.today,
        state.measurementType,
      );

      final nextMeasurement = Calendar.getNUpcomingMeasurements(
        carePlans: event.carePlans,
        reqCount: 1,
        measurementResults: todayResults,
      );

      final measurements = CarePlanHelper.getMeasurements(
        event.carePlans,
        state.selectedWhenPeriod!,
        todayResults,
      );

      emit(
        state.copyWith(
          currentCarePlans: event.carePlans,
          nextMeasurement: nextMeasurement.first,
          measurements: measurements,
          measurementType: state.measurementType,
        ),
      );
    });

    on<ReloadCarePlansEvent>(
      (event, emit) async {
        final userAccount = event.userAccount;

        getIt<SyncBloc>().add(
          SyncEvent.syncAll([userAccount]),
        );
      },
    );
  }
}
