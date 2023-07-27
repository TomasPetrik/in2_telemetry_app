import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/calendar_footer/calendar_footer_bloc.dart';
import 'package:scalesoft_app/bloc/calendar_footer/calendar_footer_event.dart';
import 'package:scalesoft_app/bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar_fulfillment_service/calendar_fulfillment_service_bloc_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/calendar_evaluation_db_provider.dart';
import 'package:scalesoft_app/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/measurements_helper.dart';

@injectable
class CalendarFulfillmentServiceBloc extends Bloc<
    CalendarFulfillmentServiceBlocEvent, CalendarFulfillmentServiceBlocState> {
  final AccountDbProvider _accountDbProvider;
  final CalendarFooterBloc _calendarFooterBloc;
  final CarePlansRepository _carePlansRepository;
  final CalendarEvaluationDbProvider _calendarEvaluationDbProvider;
  final MeasurementsDbProvider _measurementsDbProvider;
  final PendingResultsDbProvider _pendingResultsDbProvider;
  late List<MeasurementResult> offlineResults;

  CalendarFulfillmentServiceBloc(
    this._accountDbProvider,
    this._calendarFooterBloc,
    this._carePlansRepository,
    this._calendarEvaluationDbProvider,
    this._measurementsDbProvider,
    this._pendingResultsDbProvider,
  ) : super(const CalendarFulfillmentServiceBlocState()) {
    Future<void> loadAllUsersMeasurements(
      CalendarMonth calendarMonth,
      List<CarePlan> carePlans,
    ) async {
      final userAccounts =
          carePlans.fold<List<UserAccount>>([], (prevAccounts, carePlan) {
        final userAccount = _accountDbProvider.get(carePlan.userId!)!;

        return [...prevAccounts, userAccount];
      }).toSet();

      //Load all measurements results (even any out of plan)
      for (final userAccount in userAccounts) {
        if (!userAccount.viewOwnMeasurementData) {
          continue;
        }
        try {
          final supportedMeasurementTypes =
              CarePlanHelper.getMeasurementTypes(carePlans);

          final startDateTime = calendarMonth.monthStartDate;
          final endDateTime = calendarMonth.monthEndDate;

          for (final mesurementType in supportedMeasurementTypes) {
            final measurementResults = await _carePlansRepository.loadResults(
              userAccount: userAccount,
              measurementType: mesurementType,
              startDateTime: startDateTime.toIso8601String(),
              endDateTime: endDateTime.toIso8601String(),
            );
            await _measurementsDbProvider.put(
              userAccount.user.muid,
              mesurementType,
              calendarMonth.year,
              calendarMonth.month,
              MeasurementResults(items: measurementResults),
            );
          }
        } on DioError {
          debugPrint(
            'Not loaded month ${calendarMonth.month} in year ${calendarMonth.year} measurements for ${userAccount.user.fullName}',
          );
        }
      }
    }

    Future<void> loadMonthFulfillments(
      CalendarMonth calendarMonth,
      List<CarePlan> carePlans,
    ) async {
      //1. Load plan evaluation,
      for (final carePlan in carePlans) {
        final userAccount = _accountDbProvider.get(carePlan.userId!)!;
        try {
          final evaluation = await _carePlansRepository.loadPartPlanEvaluation(
            userAccount: userAccount,
            carePlanId: carePlan.id,
            fromDateTime: calendarMonth.monthStartDate.toIso8601String(),
            toDateTime: calendarMonth.monthEndDate.toIso8601String(),
          );

          await _calendarEvaluationDbProvider.put(
            carePlan.id,
            calendarMonth.year,
            calendarMonth.month,
            evaluation,
          );
        } on DioError {
          debugPrint(
            'Not loaded month ${calendarMonth.month} in year ${calendarMonth.year} fulfillments for ${userAccount.user.fullName}',
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

      //1. Get and populate month by evaluation items
      for (final carePlan in carePlans) {
        var evaluation = _calendarEvaluationDbProvider.get(
          carePlan.id,
          calendarMonth.year,
          calendarMonth.month,
        );

        if (evaluation != null) {
          evaluationItems.addAll(evaluation.items);
          carePlansEvaluations.putIfAbsent(carePlan, () => evaluation);
        }
      }

      //2. Now iterate  over each day and calculate evaluation for all careplans in calendar day

      final weeks = calendarMonth.weekDays.entries;

      for (final week in weeks) {
        final days = week.value;

        for (final day in days) {
          //Flag those days for which evaluation wasn't loaded,
          //so they shoudln't be openned to see their detail
          day.wasCheckedForEvaluation = evaluationItems.isNotEmpty;

          //get evItems which may started even in previous day,
          //but they were ended in this exact day
          final dayEvItems = evaluationItems.where((evItem) {
            return evItem.end.isAfter(day.startDt) &&
                ((evItem.end.isBefore(day.endDt) ||
                    evItem.end.isAtSameMomentAs(day.endDt)));
          }).toList();

          day.carePlansEvaluation =
              EvaluationPlanHelper.getProgressFromEvaluationItems(
            dayEvItems,
          );

          final usersEvaluationsDay =
              EvaluationPlanHelper.getUserEvaluationDays(
            calendarMonth.year,
            calendarMonth.month,
            day,
            day.userAccounts!,
            _measurementsDbProvider,
          );

          day.usersEvaluationsDay = usersEvaluationsDay;
        }
      }
    }

    Future<void> setCalendarMonth(
      CalendarMonth calendarMonth,
      List<CarePlan> carePlans,
    ) async {
      final selectedDayDt = _calendarFooterBloc.state.selectedDay?.startDt;

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

          final plannedMeasurements = Calendar.getMeasurementsOfDay(
            carePlans: carePlans,
            dayDt: day.startDt,
            offlineResults: offlineResults,
            all: true,
          );

          //filter out only future measurements which were already completed
          //it can happened for regular measurements which started and was completed before todays midnight
          //or for periodical measurements which ending in future but was completed earlier
          if (day.dayPeriod == CalendarDayPeriod.future) {
            plannedMeasurements.removeWhere(
              (pMeasurement) =>
                  pMeasurement.fulfillmentEvaluationItem?.wasMeasured() == true,
            );
          }
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

    on<CalendarFulfillmentServiceBlocEvent>((event, emit) async {
      await event.when(
        init: (calendarMonth, carePlansIds) async {
          //we need wait here because this init is invoked everytime when
          //viewPager will change pange, so we won't freeze him
          //in process of changing page during scroll
          final pendingResults = _pendingResultsDbProvider.getAll();
          offlineResults = MeasurementHelper.getOffilneResultsConverted(
            pendingResults,
            null,
            null,
          );

          final carePlans = _accountDbProvider.getCarePlans(carePlansIds);
          //await Future.delayed(const Duration(milliseconds: 700));

          await setCalendarMonth(calendarMonth, carePlans);

          if (calendarMonth.monthStartDate.isAfter(DateTime.now())) {
            emit(
              CalendarFulfillmentServiceBlocState(
                month: calendarMonth,
                loading: false,
              ),
            );
          }

          await populateMonth(calendarMonth, carePlans);
          emit(
            CalendarFulfillmentServiceBlocState(
              month: calendarMonth,
              loading: false,
            ),
          );

          if (_calendarFooterBloc.state.selectedDay == null &&
              calendarMonth.monthEndDate.isAfter(DateTime.now()) &&
              calendarMonth.monthStartDate.isBefore(DateTime.now())) {
            add(
              CalendarFulfillmentServiceBlocEvent.onDaySelected(
                DateTime.now(),
              ),
            );
          }

          if (calendarMonth.monthStartDate.isAfter(DateTime.now())) {
            debugPrint(
              'don\'t load month fullfiments for future month: ${calendarMonth.month}, year: ${calendarMonth.year}',
            );
            return;
          }

          if (calendarMonth.wasResolved != true) {
            add(
              CalendarFulfillmentServiceBlocEvent.loadMonthFulfillments(
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
          //invalidate side pages

          emit(state.copyWith(selectedDayDt: selectedDayDt));
        },
        loadMonthFulfillments: (calendarMonth, carePlans) async {
          emit(
            state.copyWith(month: calendarMonth, loading: true),
          );
          await loadMonthFulfillments(calendarMonth, carePlans);
          await loadAllUsersMeasurements(calendarMonth, carePlans);

          await populateMonth(calendarMonth, carePlans);
          calendarMonth.wasResolved = true;
          emit(
            state.copyWith(
              month: calendarMonth,
              loading: false,
            ),
          );
        },
      );
    });
  }
}
