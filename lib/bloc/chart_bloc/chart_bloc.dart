import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/chart_bloc/chart_bloc_event.dart';
import 'package:scalesoft_app/bloc/chart_bloc/chart_bloc_state.dart';
import 'package:scalesoft_app/utils/helpers/calendar_helper.dart';

@injectable
class ChartBloc extends Bloc<ChartBlocEvent, ChartBlocState> {
  late final PageController controller;
  late final BuildContext context;

  ChartBloc() : super(const ChartBlocState()) {
    DateTime getVeryFirstDtOfCarePlans(List<CarePlan> carePlans) {
      return carePlans
          .map((carePlan) => carePlan.scheduledStart)
          .sorted((a, b) => b.compareTo(a))
          .first;
    }

    on<ChartBlocEvent>((event, emit) async {
      await event.when(
        init: (context, initDate, carePlans) async {
          this.context = context;

          final fromMonthDate = getVeryFirstDtOfCarePlans(carePlans);
          final toMonthDate =
              CalendarHelper.getDateByMonthsOffset(DateTime.now(), 0);

          final months = CalendarHelper.getCalendarMonths(
            context,
            fromMonthDate,
            toMonthDate,
          )!;

          final initYear = initDate.year;
          final initMonth = initDate.month;

          final currentMonthIndex = months.indexWhere(
            (month) => month.year == initYear && month.month == initMonth,
          );

          controller = PageController(
            initialPage: currentMonthIndex,
          );

          emit(
            ChartBlocState(
              months: months,
              currentYear: initYear,
              currentMonth: initMonth,
              controller: controller,
              isCurrentMonth: true,
              currentMonthIndex: currentMonthIndex,
            ),
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
              isCurrentMonth: isCurrentMonth,
              currentMonthIndex: newPageIndex,
            ),
          );
        },
        goToPreviousMonth: () {
          final newPageIndex = state.currentMonthIndex! - 1;
          controller.jumpToPage(newPageIndex);
          //it will emit onPageChanged
        },
        goToNextMonth: () {
          final newPageIndex = state.currentMonthIndex! + 1;
          //it will emit onPageChanged
          controller.jumpToPage(newPageIndex);
        },
      );
    });
  }
}
