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
        init: (context) async {
          this.context = context;

          final todayDt = DateTime.now();
          final currentYear = todayDt.year;
          final currentMonth = todayDt.month;

          //toDate should be always 2 months ahead
          final fromDate = _session.getLatestDtOfCarePlans();
          final toDate = CalendarHelper.getDateByMonthsOffset(todayDt, 2);

          final months =
              CalendarHelper.getCalendarMonths(context, fromDate, toDate)!;

          final currentMonthIndex = months.indexWhere(
            (month) => month.year == currentYear && month.month == currentMonth,
          );

          controller = PageController(
            viewportFraction: 1.0 / 1.31,
            initialPage: currentMonthIndex,
          );

          emit(
            CalendarBlocState(
              months: months,
              currentYear: currentYear,
              currentMonth: currentMonth,
              controller: controller,
              padEnds: currentMonthIndex == months.length - 1,
              isCurrentMonth: true,
              selectedDayDt: todayDt,
              updateSelf: true,
            ),
          );
        },
        resetToToday: () async {
          final dt = DateTime.now();
          final currentYear = dt.year;
          final currentMonth = dt.month;

          final todayIndex = state.months!.indexWhere(
            (month) => month.year == currentYear && month.month == currentMonth,
          );

          final month = state.months!.firstWhere(
            (month) => month.year == currentYear && month.month == currentMonth,
          );

          _calendarFooterCubit.selectDay(null);

          final today = CalendarHelper.getDayByDateTime(month, dt);
          if (today != null) {
            _calendarFooterCubit.selectDay(today);
            add(CalendarBlocEvent.onDaySelected(today.startDt));
          }

          //it will emit onPageChanged
          controller.jumpToPage(todayIndex);
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
      );
    });
  }
}
