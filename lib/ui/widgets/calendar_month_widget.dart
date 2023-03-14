import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/calendar_service/calendar_service_bloc.dart';
import 'package:scalesoft_app/bloc/calendar_service/calendar_service_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar_service/calendar_service_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/calendar_day_planned.dart';
import 'package:scalesoft_app/ui/widgets/calendar_day_progress.dart';

class CalendarMonthWidget extends StatelessWidget {
  const CalendarMonthWidget({
    super.key,
    required this.calendarMonth,
  });

  final CalendarMonth calendarMonth;

  @override
  Widget build(BuildContext context) {
    final calServiceBloc = getIt<CalendarServiceBloc>();

    return BlocBuilder<CalendarServiceBloc, CalendarServiceBlocState>(
      bloc: calServiceBloc..add(CalendarServiceBlocEvent.init(calendarMonth)),
      builder: (context, state) {
        final loadedMonth = state.when(
          init: () => calendarMonth,
          popoulated: (calendarMonth) => calendarMonth,
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gaps.gap24,
            Text(
              '${context.locale.common_months('${loadedMonth.month}')} ${loadedMonth.year}',
              style: ScaleTextStyles.label.apply(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Gaps.gap24,
            ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: loadedMonth.weekDays.length,
              separatorBuilder: (context, index) {
                return Container(
                  margin: Paddings.vertical16,
                  height: 0.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                );
              },
              itemBuilder: (context, index) {
                final currentWeekDays = loadedMonth.weekDays[index]!;
                return Row(
                  children: currentWeekDays
                      .map(
                        (weekDay) => Expanded(
                          child: weekDay.isDayOfCurrentMonth == false
                              ? const SizedBox.shrink()
                              : Column(
                                  children: [
                                    Container(
                                      margin: Paddings.horizontal8,
                                      decoration: BoxDecoration(
                                        color: weekDay.dayPeriod ==
                                                CalendarDayPeriod.today
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : weekDay.dayPeriod ==
                                                    CalendarDayPeriod.past
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.48),
                                        borderRadius: BorderRadii.radius8,
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 1.255,
                                        child: Padding(
                                          padding: Paddings.vertical4,
                                          child: Center(
                                            child: Text(
                                              '${weekDay.dt.day}',
                                              style: ScaleTextStyles.text.apply(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Gaps.gap8,
                                    if (weekDay.dayPeriod ==
                                            CalendarDayPeriod.past ||
                                        weekDay.dayPeriod ==
                                            CalendarDayPeriod.today)
                                      CalendarDayProgress(
                                        progress: weekDay.carePlansEvaluation,
                                      )
                                    else
                                      CalendarDayPlanned(
                                        plannedMeasurements:
                                            weekDay.plannedMeasurements,
                                      )
                                  ],
                                ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
