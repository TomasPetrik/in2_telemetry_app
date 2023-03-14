import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/calendar_service/calendar_service_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar_service/calendar_service_bloc_state.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

@injectable
class CalendarServiceBloc
    extends Bloc<CalendarServiceBlocEvent, CalendarServiceBlocState> {
  final Session _session;

  CalendarServiceBloc(
    this._session,
  ) : super(
          const CalendarServiceBlocState.init(),
        ) {
    on<CalendarServiceBlocEvent>((event, emit) async {
      event.when(
        init: (calendarMonth) {
          final dtNow = DateTime.now();

          final currentMonthStartDate =
              DateUtils.addMonthsToMonthDate(dtNow, 0);
          final monthStartDate = calendarMonth.monthStartDate;

          //1. find a popoupate future measurements for current and upcomming months,
          if (DateUtils.isSameMonth(currentMonthStartDate, monthStartDate) ||
              monthStartDate.isAfter(currentMonthStartDate)) {
            final carePlans = _session.getActiveCarePlans();

            final weeks = calendarMonth.weekDays.entries;
            for (final week in weeks) {
              final days = week.value;

              for (final day in days) {
                if (day.dt.isToday() || day.dt.isAfter(dtNow)) {
                  final plannedMeasurements = Calendar.getMeasurementOfDay(
                    carePlans: carePlans,
                    weekDay: day.dt.toWeekDay(),
                  );
                  day.plannedMeasurements = plannedMeasurements;
                }
              }
            }
          }

          emit(CalendarServiceBlocState.popoulated(calendarMonth));
        },
      );
    });
  }
}
