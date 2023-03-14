import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_event.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/days_in_week_header.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/calendar_month_widget.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({
    super.key,
    required this.fromDate,
    required this.toDate,
  });

  final DateTime fromDate;
  final DateTime toDate;

  @override
  Widget build(BuildContext context) {
    final calendarBloc = getIt<CalendarBloc>();
    return Material(
      child: BlocBuilder<CalendarBloc, CalendarBlocState>(
        bloc: calendarBloc
          ..add(
            CalendarBlocEvent.init(
              context,
              fromDate,
              toDate,
            ),
          ),
        builder: (context, state) {
          if (state.months == null ||
              state.months?.isEmpty == true ||
              state.currentYear == null ||
              state.currentYear == null) {
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
                            calendarBloc
                                .add(CalendarBlocEvent.onPageChanged(newPage));
                          },
                          itemBuilder: (context, index) {
                            final month = state.months![index];
                            return Padding(
                              key: ObjectKey(month),
                              padding: Paddings.horizontal16,
                              child: CalendarMonthWidget(
                                calendarMonth: month,
                              ),
                            );
                          },
                          itemCount: state.months!.length,
                        ),
                      )
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
                          actionLabel: state.isCurrentMonth == true
                              ? null
                              : context.locale.common_today,
                          onActionTap: () => calendarBloc
                              .add(const CalendarBlocEvent.resetToToday()),
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
