import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/calendar_footer/calendar_footer_bloc.dart';
import 'package:scalesoft_app/bloc/calendar_footer/calendar_footer_event.dart';
import 'package:scalesoft_app/constants/permissions.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/providers/care_plan_db_provider.dart';
import 'package:scalesoft_app/data/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/mapper/measurement_type_mapper.dart';
import 'package:scalesoft_app/model/fulfillment_evaluation_model.dart';
import 'package:scalesoft_app/model/server_measurement_model.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/calendar_helper.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/results_helper.dart';

@injectable
class CalendarBloc extends Bloc<CalendarBlocEvent, CalendarBlocState> {
  final UserCubit _session;
  final CalendarFooterBloc _calendarFooterBloc;
  final CarePlanDbProvider _carePlanDbProvider;
  final MeasurementsDbProvider _measurementsDbProvider;
  final CarePlansRepository _carePlanRepository;
  final MeasurementTypeMapper _measurementTypeMapper;
  late final PageController controller;
  late MaterialLocalizations localizations;
  late List<CarePlan> carePlans;

  CalendarBloc(
    this._session,
    this._calendarFooterBloc,
    this._carePlanDbProvider,
    this._measurementsDbProvider,
    this._carePlanRepository,
    this._measurementTypeMapper,
  ) : super(
          const CalendarBlocState(
            padEnds: true,
            updateOnlyHeader: false,
          ),
        ) {
    on<CalendarBlocEvent>((event, emit) async {
      await event.when(
        init: (context, preSelectedDt, carePlansIds) async {
          localizations = MaterialLocalizations.of(context);

          DateTime? defaultDt = DateTime.now();
          int? defaultYear = defaultDt.year;
          int? defaultMonth = defaultDt.month;

          if (carePlansIds == null) {
            final users = _session.state.aggregateAllUsers ? _session.state.allUsers : [_session.state.currentUser];
            final userIds = users.map((x) => x.id);

            carePlans = await _carePlanDbProvider.getByUsers(userIds);
          } else {
            carePlans = await _carePlanDbProvider.getPlans(carePlansIds);
          }

          //toDate should be always 2 months ahead
          final fromDate = CarePlanHelper.getEarliestDateOfCarePlans(carePlans);
          DateTime? toDate = CalendarHelper.getDateByMonthsOffset(defaultDt, 12);
          if (preSelectedDt != null) {
            if (preSelectedDt.isAfter(toDate)) {
              toDate = CalendarHelper.getDateByMonthsOffset(preSelectedDt, 2);
            }
            defaultYear = preSelectedDt.year;
            defaultMonth = preSelectedDt.month;
            defaultDt = preSelectedDt;
          }

          final months = CalendarHelper.getCalendarMonths(localizations, fromDate, toDate)!;

          final currentMonthIndex = months.indexWhere(
            (month) => month.year == defaultYear && month.month == defaultMonth,
          );

          controller = PageController(
            viewportFraction: 1.0 / 1.31,
            initialPage: currentMonthIndex,
          );

          emit(
            CalendarBlocState(
              months: months,
              currentYear: defaultYear,
              currentMonth: defaultMonth,
              controller: controller,
              padEnds: currentMonthIndex == months.length - 1,
              isCurrentMonth: true,
              selectedDayDt: defaultDt,
              updateOnlyHeader: false,
            ),
          );

          add(CalendarBlocEvent.goOnDate(defaultDt));
        },
        goOnDate: (dt) async {
          final currentYear = dt.year;
          final currentMonth = dt.month;

          final monthIndex = state.months!.indexWhere(
            (month) => month.year == currentYear && month.month == currentMonth,
          );

          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (controller.hasClients) {
              //it will emit onPageChanged
              controller.jumpToPage(monthIndex);
            }
          });

          add(CalendarBlocEvent.onPageChanged(monthIndex));

          final month = state.months!.firstWhere(
            (month) => month.year == currentYear && month.month == currentMonth,
          );
          _calendarFooterBloc.add(const CalendarFooterEvent.selectDay(null));

          final selectedDay = CalendarHelper.getDayByDateTime(month, dt);
          if (selectedDay != null) {
            _calendarFooterBloc.add(CalendarFooterEvent.selectDay(selectedDay));
            add(CalendarBlocEvent.onDaySelected(selectedDay.startDt));
          }
        },
        onPageChanged: (int newPageIndex) async {
          final CalendarMonth selectedMonth = state.months![newPageIndex];
          final dt = DateTime.now();
          final currentYear = dt.year;
          final currentMonth = dt.month;

          final bool isCurrentMonth = selectedMonth.year == currentYear && selectedMonth.month == currentMonth;
          emit(
            state.copyWith(
              currentYear: selectedMonth.year,
              currentMonth: selectedMonth.month,
              padEnds: newPageIndex == state.months!.length - 1,
              isCurrentMonth: isCurrentMonth,
              updateOnlyHeader: true,
            ),
          );

          if (!selectedMonth.wasResolved) {
            await hydrateMonth(selectedMonth, carePlans);

            selectedMonth.wasResolved = true;

            emit(
              state.copyWith(
                updateOnlyHeader: false,
              ),
            );
          }

          add(CalendarBlocEvent.onDaySelected(state.selectedDayDt ?? DateTime.now()));
        },
        onDaySelected: (DateTime selectedDayDt) {
          //clear side months if they had some day selected
          _session.preSelectedDtRestoration = selectedDayDt;

          final currentMonthIndex = state.months?.indexWhere(
            (month) => DateUtils.isSameMonth(month.monthStartDate, selectedDayDt),
          );

          if (currentMonthIndex == null) return;

          for (final month in state.months ?? []) {
            for (final CalendarDay day in month.getCalendarDays()) {
              if (day.startDt.isSameDate(selectedDayDt)) {
                _calendarFooterBloc.add(
                  CalendarFooterEvent.selectDay(
                    day,
                  ),
                );
                day.isSelected = true;
              } else {
                day.isSelected = false;
              }
            }
          }

          emit(
            state.copyWith(
              key: UniqueKey(),
              updateOnlyHeader: false,
            ),
          );
        },
        nullDefaultDay: () {
          _session.preSelectedDtRestoration = null;
        },
      );
    });
  }

  Future<void> hydrateMonth(CalendarMonth calendarMonth, List<CarePlan> carePlans) async {
    final from = calendarMonth.monthStartDate;
    final to = calendarMonth.monthEndDate;

    final List<Measurement> offlineMeasurements = [];
    final List<FulfillmentEvaluationModel> evaluationItems = [];
    final List<ServerMeasurementModel> serverMeasurements = [];

    final measurementTypes = carePlans.map((x) => x.activity.measurementType).toSet();

    for (final measurementType in measurementTypes) {
      final carePlansOfType = carePlans.where((x) => x.activity.measurementType == measurementType);
      final userIds = carePlansOfType.map((x) => x.targetUserId).toSet();

      for (final userId in userIds) {
        final user = _session.state.allUsers.firstWhere((x) => x.id == userId);

        final offlineResults =
            await _measurementsDbProvider.getByUser(userId, from: from, to: to, ofType: measurementType);
        offlineMeasurements.addAll(offlineResults);

        final userCarePlans = carePlansOfType.where((x) => x.targetUserId == userId);

        final List<MeasurementDataContract> serverResults =
            user.permissions.contains(Permissions.viewOwnMeasurementData)
                ? await _carePlanRepository.loadResults(
                    userId: user.id,
                    measurementType: _measurementTypeMapper.convert(measurementType),
                    startDateTime: from.toIso8601String(),
                    endDateTime: to.toIso8601String(),
                  )
                : [];

        serverMeasurements
            .addAll(serverResults.map((x) => ServerMeasurementModel.fromContract(x, userId, measurementType)));

        for (final plan in userCarePlans) {
          final planEvaluationItems = await _carePlanRepository.loadPartPlanEvaluation(
            userId: userId,
            carePlanId: plan.remoteId,
            fromDateTime: from.toIso8601String(),
            toDateTime: to.toIso8601String(),
          );

          final evaluationModels =
              planEvaluationItems.map((x) => FulfillmentEvaluationModel.fromItem(x, plan.id, plan.targetUserId));
          evaluationItems.addAll(evaluationModels);
        }
      }
    }

    for (final day in calendarMonth.weekDays.values.expand((x) => x)) {
      await hydrateDay(day, offlineMeasurements, evaluationItems, serverMeasurements, carePlans);
    }
  }

  Future<void> hydrateDay(
    CalendarDay day,
    List<Measurement> offlineMeasurements,
    List<FulfillmentEvaluationModel> evaluationItems,
    List<ServerMeasurementModel> serverMeasurements,
    List<CarePlan> carePlans,
  ) async {
    final offlineMeasurementsOfDay = offlineMeasurements
        .where((x) => x.measuredAt.isAfterOrAt(day.startDt) && x.measuredAt.isBefore(day.endDt))
        .toList();

    final plannedMeasurementsOfDay = Calendar.getPlannedMeasurementsOfDay(
      carePlans: carePlans,
      dayDt: day.startDt,
      offlineResults: offlineMeasurementsOfDay,
      evaluationItems: evaluationItems,
      all: true,
    );

    final userIdsOfDay = plannedMeasurementsOfDay.map((x) => x.userId).toSet();
    final usersOfDay = _session.state.allUsers.where((x) => userIdsOfDay.contains(x.id)).toList();

    final measurementResults = ResultsHelper.getResultsOfDay(
      plannedMeasurements: plannedMeasurementsOfDay,
      measurements: offlineMeasurements,
      startOfDay: day.startDt,
      users: _session.state.allUsers.toList(),
      serverMeasurements: serverMeasurements,
    );

    final evaluationItemsOfDay = plannedMeasurementsOfDay.map((x) => x.fulfillmentEvaluationItem).nonNulls.toList();

    day.carePlansEvaluation = EvaluationPlanHelper.getProgressFromEvaluationItems(evaluationItemsOfDay);
    day.wasCheckedForEvaluation = evaluationItemsOfDay.isNotEmpty;
    day.plannedMeasurements = plannedMeasurementsOfDay;
    day.measurementResults = measurementResults;
    day.userAccounts = usersOfDay;
  }
}
