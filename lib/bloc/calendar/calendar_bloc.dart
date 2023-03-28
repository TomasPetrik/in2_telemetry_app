import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/cubit/calendar_footer/calendar_footer_cubit.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/utils/helpers/calendar_helper.dart';

@injectable
class CalendarBloc extends Bloc<CalendarBlocEvent, CalendarBlocState> {
  final Session _session;
  final CalendarFooterCubit _calendarFooterCubit;
  late final PageController controller;
  late final BuildContext context;

  CalendarBloc(
    this._session,
    this._calendarFooterCubit,
  ) : super(
          const CalendarBlocState(
            padEnds: true,
            updateSelf: false,
          ),
        ) {
    on<CalendarBlocEvent>((event, emit) async {
      await event.when(
        init: (context, preSelectedDt) async {
          this.context = context;

          DateTime? defaultDt = DateTime.now();
          int? defaultYear = defaultDt.year;
          int? defaultMonth = defaultDt.month;

          //toDate should be always 2 months ahead
          final fromDate = _session.getLatestDtOfCarePlans();
          DateTime? toDate = CalendarHelper.getDateByMonthsOffset(defaultDt, 2);
          if (preSelectedDt != null) {
            if (preSelectedDt.isAfter(toDate) == true) {
              toDate = CalendarHelper.getDateByMonthsOffset(preSelectedDt, 2);
            }
            defaultYear = preSelectedDt.year;
            defaultMonth = preSelectedDt.month;
            defaultDt = preSelectedDt;
          }

          final months =
              CalendarHelper.getCalendarMonths(context, fromDate, toDate)!;

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
              updateSelf: true,
            ),
          );

          //we need override this event because fullfillment_service_bloc is
          //updates view after 700ms
          await Future.delayed(const Duration(milliseconds: 800));
          add(CalendarBlocEvent.goOnDate(defaultDt));
        },
        goOnDate: (dt) async {
          final currentYear = dt.year;
          final currentMonth = dt.month;

          final monthIndex = state.months!.indexWhere(
            (month) => month.year == currentYear && month.month == currentMonth,
          );

          //it will emit onPageChanged
          controller.jumpToPage(monthIndex);

          final month = state.months!.firstWhere(
            (month) => month.year == currentYear && month.month == currentMonth,
          );
          _calendarFooterCubit.selectDay(null);

          final selectedDay = CalendarHelper.getDayByDateTime(month, dt);
          if (selectedDay != null) {
            _calendarFooterCubit.selectDay(selectedDay);
            add(CalendarBlocEvent.onDaySelected(selectedDay.startDt));
          }
        },
        onPageChanged: (int newPageIndex) async {
          final CalendarMonth selectedMonth = state.months![newPageIndex];

          final dt = DateTime.now();
          final currentYear = dt.year;
          final currentMonth = dt.month;

          final bool isCurrentMonth = selectedMonth.year == currentYear &&
              selectedMonth.month == currentMonth;

          emit(
            state.copyWith(
              currentYear: selectedMonth.year,
              currentMonth: selectedMonth.month,
              padEnds: newPageIndex == state.months!.length - 1,
              isCurrentMonth: isCurrentMonth,
              updateSelf: false,
            ),
          );

          if (newPageIndex == state.months!.length - 2) {
            add(const CalendarBlocEvent.addExtraMonth());
          }
        },
        addExtraMonth: () async {
          final lastMonth = state.months!.last;
          final newLastMonthDate =
              CalendarHelper.getDateByMonthsOffset(lastMonth.monthStartDate, 1);
          final newLastMonth = CalendarHelper.getCalendarMonth(
            context,
            newLastMonthDate,
          );
          state.months!.add(newLastMonth);
          await Future.delayed(const Duration(milliseconds: 700));
          emit(
            state.copyWith(
              updateSelf: true,
            ),
          );
        },
        onDaySelected: (DateTime selectedDayDt) {
          //clear side months if they had some day selected
          _session.preSelecteDtRestoration = selectedDayDt;

          final currentMonthIndex = state.months?.indexWhere(
            (month) =>
                DateUtils.isSameMonth(month.monthStartDate, selectedDayDt),
          );

          if (currentMonthIndex == null) return;

          final prevMonthIndex = currentMonthIndex - 1;
          final nextMonthIndex = currentMonthIndex + 1;

          if (prevMonthIndex >= 0) {
            state.months![prevMonthIndex].getCalendarDays().forEach((day) {
              day.isSelected = false;
            });
          }

          if (nextMonthIndex <= state.months!.length - 1) {
            state.months![nextMonthIndex].getCalendarDays().forEach((day) {
              day.isSelected = false;
            });
          }

          emit(
            state.copyWith(
              key: UniqueKey(),
              updateSelf: true,
            ),
          );
        },
        nullDefaultDay: () {
          _session.preSelecteDtRestoration = null;
        },
      );
    });
  }
}
