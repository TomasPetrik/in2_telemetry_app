import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/utils/helpers/calendar_helper.dart';

@injectable
class CalendarBloc extends Bloc<CalendarBlocEvent, CalendarBlocState> {
  late final PageController controller;

  CalendarBloc()
      : super(
          const CalendarBlocState(
            padEnds: true,
          ),
        ) {
    on<CalendarBlocEvent>((event, emit) async {
      await event.when(
        init: (context, fromDate, toDate) async {
          final months =
              CalendarHelper.getCalendarMonths(context, fromDate, toDate);

          final dt = DateTime.now();
          final currentYear = dt.year;
          final currentMonth = dt.month;

          final currentMonthIndex = months?.indexWhere(
            (month) => month.year == currentYear && month.month == currentMonth,
          );

          controller = PageController(
            viewportFraction: 1.0 / 1.31,
            initialPage: currentMonthIndex!,
          );

          emit(
            CalendarBlocState(
              months: months,
              currentYear: currentYear,
              currentMonth: currentMonth,
              controller: controller,
              padEnds: currentMonthIndex == months!.length - 1,
              isCurrentMonth: true,
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

          //it will emit onPageChanged
          controller.animateToPage(
            todayIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
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
            ),
          );
        },
      );
    });
  }
}
