import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
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
  final List<Measurement> _pendingResults = [];
  final List<CarePlan> _allCarePlans = [];
  Timer? _watchDogTimer;

  CarePlanBloc() : super(CarePlanBlocState()) {
    on<CarePlanInitializeEvent>((event, emit) async {
      _allCarePlans.clear();
      _allCarePlans.addAll(event.carePlans);
      _pendingResults.clear();
      _pendingResults.addAll(event.pendingResults ?? []);

      final List<MeasurementResult> todayOfflineResults =
          MeasurementHelper.getOffilneResultsConverted(
        _pendingResults,
        [ResultsWhenPeriod.today],
        null,
      );

      final Map<PlanWhenPeriod, int> allMeasurementCountsPerPeriod =
          CarePlanHelper.getPossibleWhenPeriods(
        _allCarePlans,
        todayOfflineResults,
      );

      final nextMeasurement = event.carePlans.isEmpty
          ? null
          : Calendar.getNUpcomingMeasurements(
              carePlans: event.carePlans,
              reqCount: 1,
              offlineResults: todayOfflineResults,
            );

      final measurements = event.carePlans.isEmpty
          ? null
          : CarePlanHelper.getMeasurements(
              event.carePlans,
              event.whenPeriod,
              todayOfflineResults,
            );

      emit(
        CarePlanBlocState(
          currentCarePlans: event.carePlans,
          selectedWhenPeriod: event.whenPeriod,
          nextMeasurement: nextMeasurement?.first,
          measurements: measurements,
          results: todayOfflineResults,
          measurementType: null,
          allMeasurementCountsPerPeriod: allMeasurementCountsPerPeriod,
        ),
      );

      _startWatchDog();
    });

    on<TimePeriodChangeEvent>((event, emit) {
      final List<MeasurementResult> todayOfflineResults =
          MeasurementHelper.getOffilneResultsConverted(
        _pendingResults,
        [ResultsWhenPeriod.today],
        state.measurementType,
      );

      final nextMeasurement = Calendar.getNUpcomingMeasurements(
        carePlans: state.currentCarePlans!,
        reqCount: 1,
        offlineResults: todayOfflineResults,
      );

      final measurements = CarePlanHelper.getMeasurements(
        state.currentCarePlans!,
        event.whenPeriod,
        todayOfflineResults,
      );

      emit(
        state.copyWith(
          selectedWhenPeriod: event.whenPeriod,
          nextMeasurement: nextMeasurement.first,
          measurements: measurements,
          results: todayOfflineResults,
        ),
      );
    });

    on<CurrentPlansChangeEvent>((event, emit) {
      final List<MeasurementResult> todayOfflineResults =
          MeasurementHelper.getOffilneResultsConverted(
        _pendingResults,
        [ResultsWhenPeriod.today],
        state.measurementType,
      );

      final carePlans = event.measurementType == null
          ? _allCarePlans
          : _allCarePlans
              .where(
                (carePlan) =>
                    carePlan.activity.measurementType == event.measurementType,
              )
              .toList();

      final nextMeasurement = Calendar.getNUpcomingMeasurements(
        carePlans: carePlans,
        reqCount: 1,
        offlineResults: todayOfflineResults,
      );

      final measurements = CarePlanHelper.getMeasurements(
        carePlans,
        state.selectedWhenPeriod!,
        todayOfflineResults,
      );

      emit(
        state.copyWith(
          currentCarePlans: carePlans,
          nextMeasurement: nextMeasurement.first,
          measurements: measurements,
          measurementType: event.measurementType,
          results: todayOfflineResults,
        ),
      );
    });

    on<ReloadCarePlansEvent>(
      (event, emit) async {
        getIt<SyncBloc>().add(
          const SyncEvent.syncAll(),
        );
      },
    );

    on<RefreshStateEvent>(
      (event, emit) async {
        final List<MeasurementResult> todayOfflineResults =
            MeasurementHelper.getOffilneResultsConverted(
          _pendingResults,
          [ResultsWhenPeriod.today],
          state.measurementType,
        );

        final carePlans = state.currentCarePlans;

        if (carePlans != null) {
          final nextMeasurement = Calendar.getNUpcomingMeasurements(
            carePlans: carePlans,
            reqCount: 1,
            offlineResults: todayOfflineResults,
          );

          final measurements = CarePlanHelper.getMeasurements(
            carePlans,
            state.selectedWhenPeriod!,
            todayOfflineResults,
          );

          emit(
            state.copyWith(
              currentCarePlans: carePlans,
              nextMeasurement: nextMeasurement.first,
              measurements: measurements,
              results: todayOfflineResults,
            ),
          );
        }
      },
    );

    on<StopWatchDog>(
      (event, emit) async {
        _watchDogTimer?.cancel();
      },
    );
  }

  Future<void> _startWatchDog() async {
    //start of exact minute
    final offsetSec = 60 - DateTime.now().second + 1;
    //debugPrint('watchdog will start after $offsetSec seconds');
    await Future.delayed(Duration(seconds: offsetSec));
    add(const RefreshStateEvent());
    //debugPrint('watchdog started on ${DateTime.now().toIso8601String()}}');
    _watchDogTimer?.cancel();
    _watchDogTimer =
        Timer.periodic(const Duration(seconds: 60), (Timer timer) async {
      //debugPrint('refreshing dashboard');
      add(const RefreshStateEvent());
    });
  }
}
