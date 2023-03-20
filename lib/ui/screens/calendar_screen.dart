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
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/future_measurements_route.dart';
import 'package:scalesoft_app/ui/routers/routes/results_history_route.dart';
import 'package:scalesoft_app/ui/routers/routes/results_route.dart';
import 'package:scalesoft_app/ui/screens/days_in_week_header.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/calendar_month_widget.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarBloc = getIt<CalendarBloc>();
    return Material(
      child: BlocBuilder<CalendarBloc, CalendarBlocState>(
        bloc: calendarBloc..add(CalendarBlocEvent.init(context)),
        builder: (context, state) {
          if (state.months == null ||
              state.months?.isEmpty == true ||
              state.currentYear == null ||
              state.currentMonth == null) {
            return const SizedBox.shrink();
          } else {
            return Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      Gap(
                        MediaQuery.of(context).viewPadding.top +
                            Constants.appBarHeight,
                      ),
                      SizedBox(
                        height: (24 +
                                16 +
                                24 +
                                (5 * (16 + 28 + 8 + 4 + 16 + 0.5))) *
                            1.31,
                        child: PageView.builder(
                          scrollDirection: Axis.vertical,
                          padEnds: state.padEnds,
                          controller: state.controller,
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
                              ),
                            );
                          },
                          itemCount: state.months!.length,
                        ),
                      ),
                      const Padding(
                        padding: Paddings.horizontal16,
                        child: _CalendarFooter(),
                      ),
                    ],
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
                        ScaleAppBar(
                          title:
                              '${context.locale.common_months('${state.currentMonth}')} ${state.currentYear}',
                          showClose: true,
                          customLeftWidget: state.isCurrentMonth == true
                              ? null
                              : TextButton(
                                  onPressed: () {
                                    calendarBloc.add(
                                      const CalendarBlocEvent.resetToToday(),
                                    );
                                  },
                                  child: Text(
                                    context.locale.common_today,
                                    style: ScaleTextStyles.text.apply(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                        ),
                        const Padding(
                          padding: Paddings.top16,
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
            );
          }
        },
      ),
    );
  }
}

class _CalendarFooter extends StatelessWidget {
  const _CalendarFooter();

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

              switch (selectedDay.dayPeriod) {
                case CalendarDayPeriod.past:
                  GoRouter.of(context).pushNamed(
                    ResultsHistoryRoute.name,
                    extra: usersEvaluationsDay,
                  );
                  break;
                case CalendarDayPeriod.today:
                  GoRouter.of(context).goNamed(ResultsRoute.name);
                  break;
                case CalendarDayPeriod.future:
                  GoRouter.of(context).pushNamed(
                    FutureMeasurementsRoute.name,
                    extra: usersEvaluationsDay,
                  );
                  break;
              }
            },
            child: Column(
              children: [
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
                              ' ${selectedDay.userAccounts!.length > 1 ? context.locale.common_plus_n_others(selectedDay.userAccounts!.length - 1) : ''}',
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
                        '${selectedDay.plannedMeasurements?.length ?? 0} ${context.locale.common_measurement.toLowerCase()}',
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
