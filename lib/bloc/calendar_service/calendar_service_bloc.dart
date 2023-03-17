import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/calendar_service/calendar_service_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar_service/calendar_service_bloc_state.dart';
import 'package:scalesoft_app/cubit/calendar_footer/calendar_footer_cubit.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/calendar_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/calendar_helper.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';

@injectable
class CalendarServiceBloc
    extends Bloc<CalendarServiceBlocEvent, CalendarServiceBlocState> {
  final Session _session;
  final AccountDbProvider _accountDbProvider;
  final CalendarFooterCubit _calendarFooterCubit;
  final CarePlansRepository _carePlansRepository;
  final CalendarDbProvider _calendarDbProvider;
  final PendingResultsDbProvider _pendingResultsDbProvider;

  CalendarServiceBloc(
    this._session,
    this._accountDbProvider,
    this._calendarFooterCubit,
    this._carePlansRepository,
    this._calendarDbProvider,
    this._pendingResultsDbProvider,
  ) : super(
          const CalendarServiceBlocState(),
        ) {
    Future<void> loadMonthFulfillments(
      CalendarMonth calendarMonth,
      List<CarePlan> carePlans,
    ) async {
      //2. find and populate past and ongoing month,
      for (final carePlan in carePlans) {
        final userAccount = _accountDbProvider.get(carePlan.userId!)!;
        try {
          final evaluation = await _carePlansRepository.loadPartPlanEvaluation(
            userAccount: userAccount,
            carePlanId: carePlan.id,
            fromDateTime: calendarMonth.monthStartDate.toIso8601String(),
            toDateTime: calendarMonth.monthEndDate.toIso8601String(),
          );

          await _calendarDbProvider.put(
            carePlan.id,
            calendarMonth.year,
            calendarMonth.month,
            evaluation,
          );
        } on DioError {
          debugPrint(
            'not loaded month fulfillments for ${userAccount.user.fullName}',
          );
        }
      }
    }

    Future<void> populateMonth(
      CalendarMonth calendarMonth,
      List<CarePlan> carePlans,
    ) async {
      /*
      debugPrint(
        'start getting info for ev days int dates ${calendarMonth.monthStartDate} - ${calendarMonth.monthEndDate}',
      );
      */
      Map<CarePlan, FulfillmentEvaluation> carePlansEvaluations = {};
      List<FulfillmentEvaluationItem> evaluationItems = [];

      //1. Find and populate past and ongoing month,
      for (final carePlan in carePlans) {
        var evaluation = _calendarDbProvider.get(
          carePlan.id,
          calendarMonth.year,
          calendarMonth.month,
        );

        if (evaluation != null) {
          evaluationItems.addAll(evaluation.items);
          carePlansEvaluations.putIfAbsent(carePlan, () => evaluation);
        }
      }

      //2. Now iterate  over each day and calculate evaluation for all careplans
      //in calendar day

      if (evaluationItems.isEmpty) {
        return;
      }

      final weeks = calendarMonth.weekDays.entries;

      for (final week in weeks) {
        final days = week.value;

        for (final day in days) {
          if ((day.dayPeriod != CalendarDayPeriod.past &&
                  day.dayPeriod != CalendarDayPeriod.today) ||
              !day.isDayOfCurrentMonth) {
            continue;
          }

          final dayEvItems = evaluationItems.where((evItem) {
            return evItem.start.isAtSameMomentAs(day.startDt) ||
                (evItem.start.isAfter(day.startDt) &&
                    evItem.start.isBefore(day.endDt));
          }).toList();

          day.carePlansEvaluation =
              EvaluationPlanHelper.getProgressFromEvaluationItems(dayEvItems);

          day.usersEvaluationsDay = EvaluationPlanHelper.getUserEvaluationDays(
            calendarMonth.year,
            calendarMonth.month,
            day,
            day.userAccounts!,
          );
        }
      }
    }

    Future<void> setCalendarMonth(
      CalendarMonth calendarMonth,
      List<CarePlan> carePlans,
    ) async {
      final selectedDayDt = _calendarFooterCubit.state.selectedDay?.startDt;

      //1. popoupate planned measurements for current and upcomming days,

      final weeks = calendarMonth.weekDays.entries;
      for (final week in weeks) {
        final days = week.value;

        for (final day in days) {
          if (selectedDayDt?.isSameDate(day.startDt) == true) {
            day.isSelected = true;
          } else {
            day.isSelected = false;
          }

          final plannedMeasurements = Calendar.getMeasurementOfDay(
            carePlans: carePlans,
            dayDt: day.startDt,
          );
          day.plannedMeasurements = plannedMeasurements;

          final userAccounts = plannedMeasurements
              .map(
                (plMeasurement) =>
                    _accountDbProvider.get(plMeasurement.userId)!,
              )
              .toSet();

          day.userAccounts = userAccounts.toList();
        }
      }
    }

    on<CalendarServiceBlocEvent>((event, emit) async {
      await event.when(
        init: (calendarMonth, selectedDayDt) async {
          await Future.delayed(const Duration(milliseconds: 700));

          final carePlans = _session.getActiveCarePlans();
          await setCalendarMonth(calendarMonth, carePlans);
          if (calendarMonth.monthStartDate.isAfter(DateTime.now())) {
            emit(
              CalendarServiceBlocState(month: calendarMonth, loading: false),
            );
            return;
          }

          final todayDt = DateTime.now();
          final today = CalendarHelper.getDayByDateTime(calendarMonth, todayDt);
          if (todayDt.isAfter(calendarMonth.monthStartDate) &&
              todayDt.isBefore(calendarMonth.monthEndDate) &&
              calendarMonth.wasInit != true) {
            calendarMonth.wasInit = true;
            today?.isSelected = true;
            _calendarFooterCubit.selectDay(today);
          }

          await populateMonth(calendarMonth, carePlans);

          if (calendarMonth.wasResolved != true) {
            add(
              CalendarServiceBlocEvent.loadMonthFulfillments(
                calendarMonth,
                carePlans,
              ),
            );
          }
        },
        onDaySelected: (selectedDayDt) {
          for (final week in state.month!.weekDays.entries) {
            for (final day in week.value) {
              if (day.startDt.isSameDate(selectedDayDt)) {
                _calendarFooterCubit.selectDay(day);
                day.isSelected = true;
              } else {
                day.isSelected = false;
              }
            }
          }
          emit(state.copyWith(selectedDayDt: selectedDayDt));
        },
        loadMonthFulfillments: (calendarMonth, carePlans) async {
          emit(
            CalendarServiceBlocState(month: calendarMonth, loading: true),
          );
          await loadMonthFulfillments(calendarMonth, carePlans);
          await populateMonth(calendarMonth, carePlans);
          emit(
            CalendarServiceBlocState(
              month: calendarMonth,
              loading: false,
              wasResolved: true,
            ),
          );
        },
      );
    });
  }
}
