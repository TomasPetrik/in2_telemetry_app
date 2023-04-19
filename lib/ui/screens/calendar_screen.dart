import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_day.dart';
import 'package:scalesoft_app/cubit/calendar_footer/calendar_footer_cubit.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/future_measurements_route.dart';
import 'package:scalesoft_app/ui/routers/routes/results_history_route.dart';
import 'package:scalesoft_app/ui/routers/routes/results_route.dart';
import 'package:scalesoft_app/ui/screens/days_in_week_header.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/calendar_month_widget.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({
    super.key,
    this.preSelectedDt,
    required this.carePlansIds,
  });

  final DateTime? preSelectedDt;
  final List<int> carePlansIds;

  @override
  Widget build(BuildContext context) {
    final calendarBloc = getIt<CalendarBloc>()
      ..add(CalendarBlocEvent.init(context, preSelectedDt, carePlansIds));

    Future<bool> onWillPop() async {
      calendarBloc.add(const CalendarBlocEvent.nullDefaultDay());
      return true;
    }

    bool isSmallDisplay = (MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewPadding.top -
            Dimensions.appBarHeight -
            Dimensions.calendarHeight) <
        Dimensions.footerHeight;

    return WillPopScope(
      onWillPop: onWillPop,
      child: Material(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Gap(
                    MediaQuery.of(context).viewPadding.top +
                        Dimensions.appBarHeight,
                  ),
                  SizedBox(
                    height: Dimensions.calendarHeight,
                    child: BlocBuilder<CalendarBloc, CalendarBlocState>(
                      bloc: calendarBloc,
                      buildWhen: (previous, current) {
                        return current.updateSelf;
                      },
                      builder: (context, state) {
                        if (state.months == null ||
                            state.months?.isEmpty == true ||
                            state.currentYear == null ||
                            state.currentMonth == null) {
                          return const SizedBox.shrink();
                        } else {
                          return PageView.builder(
                            scrollDirection: Axis.vertical,
                            padEnds: false, //state.padEnds,
                            controller: state.controller,
                            //allowImplicitScrolling: true,
                            onPageChanged: (newPage) {
                              calendarBloc.add(
                                CalendarBlocEvent.onPageChanged(newPage),
                              );
                            },
                            itemBuilder: (context, index) {
                              final month = state.months![index];
                              return Padding(
                                key: ValueKey(index),
                                padding: Paddings.horizontal16,
                                child: CalendarMonthWidget(
                                  calendarMonth: month,
                                  calendarBloc: calendarBloc,
                                  carePlansIds: carePlansIds,
                                ),
                              );
                            },
                            itemCount: state.months!.length,
                          );
                        }
                      },
                    ),
                  ),
                  if (!isSmallDisplay)
                    const Padding(
                      padding: Paddings.horizontal16,
                      child: _CalendarFooter(
                        isDownSticky: false,
                      ),
                    ),
                ],
              ),
            ),
            if (isSmallDisplay)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: Paddings.horizontal16,
                  color: Theme.of(context).colorScheme.surface,
                  child: const _CalendarFooter(
                    isDownSticky: true,
                  ),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Theme.of(context).colorScheme.background,
                child: Column(
                  children: [
                    BlocBuilder<CalendarBloc, CalendarBlocState>(
                      bloc: calendarBloc,
                      builder: (context, state) {
                        if (state.months == null ||
                            state.months?.isEmpty == true ||
                            state.currentYear == null ||
                            state.currentMonth == null) {
                          return const SizedBox.shrink();
                        } else {
                          return ScaleAppBar(
                            title:
                                '${translactions.common_months(Constants.monthsInYear[state.currentMonth!]!)} ${state.currentYear}',
                            showClose: true,
                            onCloseTap: onWillPop,
                            customLeftWidget: state.isCurrentMonth == true
                                ? null
                                : InkWell(
                                    onTap: () {
                                      calendarBloc.add(
                                        CalendarBlocEvent.goOnDate(
                                          DateTime.now(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      translactions.common_today,
                                      style: ScaleTextStyles.text.apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                          );
                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: Dimensions.padding16,
                        left: Dimensions.padding16,
                        right: Dimensions.padding16,
                      ),
                      child: DaysInWeekHeader(),
                    ),
                    Container(
                      margin: Paddings.horizontal16,
                      height: 0.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarFooter extends StatelessWidget {
  const _CalendarFooter({
    required this.isDownSticky,
  });

  final bool isDownSticky;

  @override
  Widget build(BuildContext context) {
    final calendarFooterCubit = getIt<CalendarFooterCubit>();
    final session = getIt<Session>();
    return BlocBuilder<CalendarFooterCubit, CalendarFooterState>(
      bloc: calendarFooterCubit..selectDay(null),
      builder: (context, state) {
        final selectedDay = state.selectedDay;
        if (selectedDay == null ||
            selectedDay.plannedMeasurements == null ||
            selectedDay.plannedMeasurements!.isEmpty) {
          return const SizedBox.shrink();
        } else {
          return InkWell(
            onTap: () {
              final usersEvaluationsDay =
                  EvaluationPlanHelper.getUserEvaluationDays(
                selectedDay.startDt.year,
                selectedDay.startDt.month,
                selectedDay,
                session.getSessionAccounts(),
              );

              session.usersEvaluationsDayRestoration = usersEvaluationsDay;

              switch (selectedDay.dayPeriod) {
                case CalendarDayPeriod.past:
                  GoRouter.of(context).pushNamed(
                    ResultsHistoryRoute.name,
                  );
                  break;
                case CalendarDayPeriod.today:
                  GoRouter.of(context).goNamed(ResultsRoute.name);
                  break;
                case CalendarDayPeriod.future:
                  GoRouter.of(context).pushNamed(
                    FutureMeasurementsRoute.name,
                  );
                  break;
              }
            },
            child: Column(
              children: [
                if (isDownSticky)
                  Container(
                    height: 0.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                Padding(
                  padding: Paddings.vertical16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/icon_wave_pulse.svg',
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      Gaps.gap16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedDay.startDt.toRegularDate(),
                              style: ScaleTextStyles.textAccent.apply(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Gaps.gap6,
                            Text(
                              '${selectedDay.userAccounts!.first.user.fullName}'
                              ' ${selectedDay.userAccounts!.length > 1 ? translactions.common_plus_n_others(selectedDay.userAccounts!.length - 1) : ''}',
                              style: ScaleTextStyles.label.apply(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            )
                          ],
                        ),
                      ),
                      Gaps.gap16,
                      Text(
                        '${selectedDay.plannedMeasurements?.length ?? 0} ${translactions.common_measurement.toLowerCase()}',
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      Gaps.gap16,
                      SvgPicture.asset(
                        'assets/icons/icon_arrow_sm_right.svg',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                if (!isDownSticky)
                  Container(
                    height: 0.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}
