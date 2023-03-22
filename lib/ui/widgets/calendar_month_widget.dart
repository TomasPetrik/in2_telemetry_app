import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/bloc/calendar_service/fulfillment_service_bloc.dart';
import 'package:scalesoft_app/bloc/calendar_service/fulfillment_service_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar_service/fulfillment_service_bloc_state.dart';
import 'package:scalesoft_app/cubit/calendar_footer/calendar_footer_cubit.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/calendar_day_planned.dart';
import 'package:scalesoft_app/ui/widgets/calendar_day_progress.dart';
import 'package:scalesoft_app/ui/widgets/rotating_icon.dart';

class CalendarMonthWidget extends StatelessWidget {
  const CalendarMonthWidget({
    super.key,
    required this.calendarMonth,
    required this.calendarBloc,
  });

  final CalendarMonth calendarMonth;
  final CalendarBloc calendarBloc;

  @override
  Widget build(BuildContext context) {
    final calendarServiceBloc = getIt<FulfillmentServiceBloc>();
    final carePlans = getIt<Session>().getAllCarePlans();

    return BlocBuilder<FulfillmentServiceBloc, FulfillmentServiceBlocState>(
      bloc: calendarServiceBloc
        ..add(
          FulfillmentServiceBlocEvent.init(
            calendarMonth,
            carePlans,
          ),
        ),
      builder: (context, state) {
        final CalendarMonth loadedMonth;
        if (state.month != null) {
          loadedMonth = state.month!;
        } else {
          loadedMonth = calendarMonth;
        }

        return Stack(
          children: [
            Column(
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
                      children: currentWeekDays.map((day) {
                        /*
                        debugPrint(
                          'Evaluation ${day.startDt.toRegularDate()} : ${day.carePlansEvaluation} vs. ${day.evaluationPercentage}',
                        );
                        */

                        return Expanded(
                          child: day.isDayOfCurrentMonth == false
                              ? const SizedBox.shrink()
                              : Column(
                                  children: [
                                    Container(
                                      margin: Paddings.horizontal8,
                                      decoration: BoxDecoration(
                                        color: day.isSelected == true
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : day.dayPeriod ==
                                                    CalendarDayPeriod.today
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .tertiary
                                                : day.dayPeriod ==
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
                                      child: InkWell(
                                        onTap: () {
                                          calendarServiceBloc.add(
                                            FulfillmentServiceBlocEvent
                                                .onDaySelected(
                                              day.startDt,
                                            ),
                                          );
                                          calendarBloc.add(
                                            CalendarBlocEvent.onDaySelected(
                                              day.startDt,
                                            ),
                                          );
                                          getIt<CalendarFooterCubit>()
                                              .selectDay(day);
                                        },
                                        child: AspectRatio(
                                          aspectRatio: 1.255,
                                          child: Padding(
                                            padding: Paddings.vertical4,
                                            child: Center(
                                              child: Text(
                                                '${day.startDt.day}',
                                                style:
                                                    ScaleTextStyles.text.apply(
                                                  color: day.isSelected ==
                                                              true ||
                                                          day.dayPeriod !=
                                                              CalendarDayPeriod
                                                                  .future
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onPrimary
                                                          .withOpacity(0.48),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Gaps.gap8,
                                    if (day.dayPeriod ==
                                            CalendarDayPeriod.past ||
                                        day.dayPeriod ==
                                            CalendarDayPeriod.today)
                                      CalendarDayProgress(
                                        progress: day.evaluationPercentage,
                                      )
                                    else
                                      CalendarDayPlanned(
                                        plannedMeasurements:
                                            day.plannedMeasurements,
                                      )
                                  ],
                                ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
            if (state.loading == true)
              Positioned.fill(
                child: Center(
                  child: RotatingIcon(
                    child: SvgPicture.asset(
                      'assets/icons/icon_loader.svg',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
