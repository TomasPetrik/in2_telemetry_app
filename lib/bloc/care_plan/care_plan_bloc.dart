import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/care_pan/care_plan_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

@singleton
class CarePlanBloc extends Bloc<CarePlanBlocEvent, CarePlanBlocState> {
  final List<Measurement> _pendingResults = [];
  final List<CarePlanContract> _allCarePlans = [];

  CarePlanBloc() : super(CarePlanBlocState()) {
    on<CarePlanInitializeEvent>((event, emit) async {
      _allCarePlans.clear();
      _allCarePlans.addAll(event.carePlans);
      _pendingResults.clear();
      _pendingResults.addAll(event.pendingResults);

      final List<MeasurementDataContract> todayOfflineResults =
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

      final upcomingMeasurements = CarePlanHelper.getMeasurementsForPeriod(
        event.carePlans,
        event.whenPeriod,
        todayOfflineResults,
      );

      final allTodayMeasurements = Calendar.getMeasurementsOfDay(
        carePlans: event.carePlans,
        dayDt: DateTime.now().date,
        offlineResults: todayOfflineResults,
        all: true,
      );

      emit(
        CarePlanBlocState(
          timestamp: DateTime.now().microsecondsSinceEpoch,
          currentCarePlans: event.carePlans,
          selectedWhenPeriod: event.whenPeriod,
          nextMeasurement: nextMeasurement?.first,
          upcomingMeasurements: upcomingMeasurements,
          allTodayMeasurements: allTodayMeasurements,
          results: todayOfflineResults,
          measurementType: null,
          allMeasurementCountsPerPeriod: allMeasurementCountsPerPeriod,
        ),
      );
    });

    on<TimePeriodChangeEvent>((event, emit) {
      final List<MeasurementDataContract> todayOfflineResults =
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

      final upcomingMeasurements = CarePlanHelper.getMeasurementsForPeriod(
        state.currentCarePlans!,
        event.whenPeriod,
        todayOfflineResults,
      );

      final allTodayMeasurements = Calendar.getMeasurementsOfDay(
        carePlans: state.currentCarePlans!,
        dayDt: DateTime.now().date,
        offlineResults: todayOfflineResults,
        all: true,
      );

      emit(
        state.copyWith(
          selectedWhenPeriod: event.whenPeriod,
          nextMeasurement: nextMeasurement.first,
          upcomingMeasurements: upcomingMeasurements,
          allTodayMeasurements: allTodayMeasurements,
          results: todayOfflineResults,
        ),
      );
    });

    on<CurrentPlansChangeEvent>((event, emit) {
      final List<MeasurementDataContract> todayOfflineResults =
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

      final upcomingMeasurements = CarePlanHelper.getMeasurementsForPeriod(
        carePlans,
        state.selectedWhenPeriod!,
        todayOfflineResults,
      );

      final allTodayMeasurements = Calendar.getMeasurementsOfDay(
        carePlans: carePlans,
        dayDt: DateTime.now().date,
        offlineResults: todayOfflineResults,
        all: true,
      );

      emit(
        state.copyWith(
          currentCarePlans: carePlans,
          nextMeasurement: nextMeasurement.first,
          upcomingMeasurements: upcomingMeasurements,
          allTodayMeasurements: allTodayMeasurements,
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
        final List<MeasurementDataContract> todayOfflineResults =
            MeasurementHelper.getOffilneResultsConverted(
          _pendingResults,
          [ResultsWhenPeriod.today],
          state.measurementType,
        );

        final carePlans = state.currentCarePlans;

        if (carePlans != null && carePlans.isNotEmpty) {
          final nextMeasurement = Calendar.getNUpcomingMeasurements(
            carePlans: carePlans,
            reqCount: 1,
            offlineResults: todayOfflineResults,
          );

          final upcomingMeasurements = CarePlanHelper.getMeasurementsForPeriod(
            carePlans,
            state.selectedWhenPeriod!,
            todayOfflineResults,
          );

          final allTodayMeasurements = Calendar.getMeasurementsOfDay(
            carePlans: carePlans,
            dayDt: DateTime.now().date,
            offlineResults: todayOfflineResults,
            all: true,
          );

          emit(
            state.copyWith(
              timestamp: DateTime.now().microsecondsSinceEpoch,
              currentCarePlans: carePlans,
              nextMeasurement: nextMeasurement.first,
              upcomingMeasurements: upcomingMeasurements,
              allTodayMeasurements: allTodayMeasurements,
              results: todayOfflineResults,
            ),
          );
        }
      },
    );
  }
}
