import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_event.dart';
import 'package:scalesoft_app/bloc/care_plan/care_plan_bloc_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/data/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';

@singleton
class CarePlanBloc extends Bloc<CarePlanBlocEvent, CarePlanBlocState> {
  final UserCubit _session;
  final CarePlanDbProvider _carePlanDbProvider;
  final MeasurementsDbProvider _measurementsDbProvider;

  final List<Measurement> _pendingResults = [];
  final List<CarePlan> _allCarePlans = [];

  CarePlanBloc(this._session, this._carePlanDbProvider, this._measurementsDbProvider) : super(CarePlanBlocState()) {
    on<CarePlanInitializeEvent>((event, emit) async {
      final yesterdayStart = DateTime.now().yesterday;

      final userIds = event.users.map((x) => x.id);

      final carePlans = await _carePlanDbProvider.getByUsers(userIds);
      final activeCarePlans = carePlans
          .where((x) => x.versions.any((version) => version.activeTo?.isAfter(yesterdayStart) ?? true))
          .toList();

      final allPendingResults = await _measurementsDbProvider.getByUsers(userIds, from: yesterdayStart);

      _allCarePlans.clear();
      _allCarePlans.addAll(activeCarePlans);
      _pendingResults.clear();
      _pendingResults.addAll(allPendingResults);

      final List<Measurement> todayOfflineResults = MeasurementHelper.filterMeasurements(
        _pendingResults,
        [ResultsWhenPeriod.today],
        null,
      );

      final Map<PlanWhenPeriod, int> allMeasurementCountsPerPeriod = CarePlanHelper.getPossibleWhenPeriods(
        _allCarePlans,
        todayOfflineResults,
      );

      final nextMeasurement = activeCarePlans.isEmpty
          ? null
          : Calendar.getNUpcomingMeasurements(
              carePlans: activeCarePlans,
              reqCount: 1,
              offlineResults: todayOfflineResults,
            );

      final plannedMeasurements = Calendar.getPlannedMeasurementsOfDay(
        carePlans: activeCarePlans,
        dayDt: DateTime.now().date,
        offlineResults: todayOfflineResults,
        all: true,
      );

      final allTodayMeasurements = ResultsHelper.getResultsOfDay(
        plannedMeasurements: plannedMeasurements,
        measurements: todayOfflineResults,
        startOfDay: DateTime.now().startOfDay,
        users: event.users,
      );

      emit(
        CarePlanBlocState(
          timestamp: DateTime.now().microsecondsSinceEpoch,
          carePlansOfType: activeCarePlans,
          selectedWhenPeriod: event.whenPeriod,
          nextMeasurement: nextMeasurement?.first,
          allTodayMeasurements: allTodayMeasurements,
          results: _pendingResults,
          measurementType: null,
          allMeasurementCountsPerPeriod: allMeasurementCountsPerPeriod,
          allCarePlans: activeCarePlans,
        ),
      );
    });

    on<TimePeriodChangeEvent>((event, emit) {
      final List<Measurement> todayOfflineResults = MeasurementHelper.filterMeasurements(
        _pendingResults,
        [ResultsWhenPeriod.today],
        state.measurementType,
      );

      final nextMeasurement = Calendar.getNUpcomingMeasurements(
        carePlans: state.carePlansOfType!,
        reqCount: 1,
        offlineResults: todayOfflineResults,
      );

      final plannedMeasurements = CarePlanHelper.getMeasurementsForPeriod(
        state.carePlansOfType!,
        event.whenPeriod,
        todayOfflineResults,
        all: true,
      );

      final allTodayMeasurements = ResultsHelper.getResultsOfDay(
        plannedMeasurements: plannedMeasurements,
        measurements: todayOfflineResults,
        startOfDay: DateTime.now().startOfDay,
        users: _session.state.allUsers.toList(),
      );

      emit(
        state.copyWith(
          selectedWhenPeriod: event.whenPeriod,
          nextMeasurement: nextMeasurement.first,
          allTodayMeasurements: allTodayMeasurements,
          results: _pendingResults,
        ),
      );
    });

    on<MeasurementTypeChangeEvent>((event, emit) {
      final List<Measurement> todayOfflineResults = MeasurementHelper.filterMeasurements(
        _pendingResults,
        [ResultsWhenPeriod.today],
        state.measurementType,
      );

      final carePlans = event.measurementType == null
          ? _allCarePlans
          : _allCarePlans
              .where(
                (carePlan) => carePlan.activity.measurementType == event.measurementType,
              )
              .toList();

      final nextMeasurement = Calendar.getNUpcomingMeasurements(
        carePlans: carePlans,
        reqCount: 1,
        offlineResults: todayOfflineResults,
      );

      final plannedMeasurements = CarePlanHelper.getMeasurementsForPeriod(
        carePlans,
        state.selectedWhenPeriod!,
        todayOfflineResults,
        all: true,
      );

      final allTodayMeasurements = ResultsHelper.getResultsOfDay(
        plannedMeasurements: plannedMeasurements,
        measurements: todayOfflineResults,
        startOfDay: DateTime.now().startOfDay,
        users: _session.state.allUsers.toList(),
      );

      emit(
        state.copyWith(
          carePlansOfType: carePlans,
          nextMeasurement: nextMeasurement.first,
          allTodayMeasurements: allTodayMeasurements,
          measurementType: event.measurementType,
          results: _pendingResults,
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
        final List<Measurement> todayOfflineResults = MeasurementHelper.filterMeasurements(
          _pendingResults,
          [ResultsWhenPeriod.today],
          state.measurementType,
        );

        final carePlans = state.carePlansOfType;

        if (carePlans != null && carePlans.isNotEmpty) {
          final nextMeasurement = Calendar.getNUpcomingMeasurements(
            carePlans: carePlans,
            reqCount: 1,
            offlineResults: todayOfflineResults,
          );

          final plannedMeasurements = CarePlanHelper.getMeasurementsForPeriod(
            carePlans,
            state.selectedWhenPeriod!,
            todayOfflineResults,
            all: true,
          );

          final allTodayMeasurements = ResultsHelper.getResultsOfDay(
            plannedMeasurements: plannedMeasurements,
            measurements: todayOfflineResults,
            startOfDay: DateTime.now().startOfDay,
            users: _session.state.allUsers.toList(),
          );

          emit(
            state.copyWith(
              timestamp: DateTime.now().microsecondsSinceEpoch,
              carePlansOfType: carePlans,
              nextMeasurement: nextMeasurement.first,
              allTodayMeasurements: allTodayMeasurements,
              results: _pendingResults,
            ),
          );
        }
      },
    );
  }
}
