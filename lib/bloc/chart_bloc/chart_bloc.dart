import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/chart_bloc/chart_bloc_event.dart';
import 'package:scalesoft_app/bloc/chart_bloc/chart_bloc_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/utils/helpers/calendar_helper.dart';

@injectable
class ChartBloc extends Bloc<ChartBlocEvent, ChartBlocState> {
  late final PageController controller;
  late final BuildContext context;

  ChartBloc() : super(const ChartBlocState()) {
    DateTime getVeryFirstmodelfCarePlans(
      List<CarePlan> carePlans,
      UserAccount userAccount,
    ) {
      if (carePlans.isNotEmpty) {
        return carePlans
            .map((carePlan) => carePlan.scheduledStart)
            .sorted((a, b) => b.compareTo(a))
            .first;
      } else {
        return userAccount.measurementResults!.first.measurementDateTime;
      }
    }

    Future<List<DrawableRoot>> loadSvgDrawables(Color color) async {
      List<DrawableRoot> drawableRoots = [];
      int i = 0;
      for (final iconRaw in iconsRaw) {
        final coloredRawIcon = iconRaw.replaceAll(
          "#000000",
          '#${color.value.toRadixString(16).padLeft(6, '0').toUpperCase()}',
        );
        drawableRoots
            .add(await svg.fromSvgString(coloredRawIcon, 'icon${i}Raw'));
        i += 1;
      }

      return drawableRoots;
    }

    on<ChartBlocEvent>((event, emit) async {
      await event.when(
        init: (context, initDate, userAccount, carePlans, color) async {
          this.context = context;

          final fromMonthDate =
              getVeryFirstmodelfCarePlans(carePlans, userAccount);
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

          final svgDrawables = await loadSvgDrawables(color);

          emit(
            ChartBlocState(
              months: months,
              currentYear: initYear,
              currentMonth: initMonth,
              controller: controller,
              isCurrentMonth: true,
              currentMonthIndex: currentMonthIndex,
              svgDrawables: svgDrawables,
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

const List<String> iconsRaw = [
  '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M3 10H21M7 3V5M17 3V5M6.2 21H17.8C18.9201 21 19.4802 21 19.908 20.782C20.2843 20.5903 20.5903 20.2843 20.782 19.908C21 19.4802 21 18.9201 21 17.8V8.2C21 7.07989 21 6.51984 20.782 6.09202C20.5903 5.71569 20.2843 5.40973 19.908 5.21799C19.4802 5 18.9201 5 17.8 5H6.2C5.0799 5 4.51984 5 4.09202 5.21799C3.71569 5.40973 3.40973 5.71569 3.21799 6.09202C3 6.51984 3 7.07989 3 8.2V17.8C3 18.9201 3 19.4802 3.21799 19.908C3.40973 20.2843 3.71569 20.5903 4.09202 20.782C4.51984 21 5.07989 21 6.2 21Z" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>''',
  '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><g>
<path d="M12 7V12L14.5 13.5M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</g></svg>''',
  '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M3 12H7L9 19L12 5L15 17L17 12H21" stroke="#000000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>'''
];
