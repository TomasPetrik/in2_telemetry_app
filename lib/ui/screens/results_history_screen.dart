import 'package:flutter/material.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/history_multi_user_evaluation_header.dart';
import 'package:scalesoft_app/ui/widgets/history_results_list.dart';
import 'package:scalesoft_app/ui/widgets/history_single_user_evaluation_header.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class ResultsHistoryScreen extends StatelessWidget {
  ResultsHistoryScreen({
    super.key,
    required this.usersEvaluationsDay,
  }) : assert(
          usersEvaluationsDay.isNotEmpty,
          'To show history page must be included at least one evaluation date !',
        );

  final List<UserEvaluationDay> usersEvaluationsDay;

  @override
  Widget build(BuildContext context) {
    final date = usersEvaluationsDay.first.dt;
    final userNames = usersEvaluationsDay.map((evDay) => evDay.userName);

    final bool isMultiUser = usersEvaluationsDay.length > 1;

    final historicMeasurements =
        usersEvaluationsDay.fold<List<HistoricMeasurement>>(
      [],
      (previousValue, userEvaluationsDay) => [
        ...previousValue,
        ...userEvaluationsDay.getHistoricMeasurement(),
      ],
    )..sort(
            (a, b) => b.whenStart.compareTo(a.whenStart),
          );

    final measurementTypes = historicMeasurements
        .map((measurement) => measurement.carePlan.activity.measurementType)
        .toSet();

    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: NavigationScreen(
              topSlivers: [
                isMultiUser
                    ? HistoryMultiUserEvaluationHeader(
                        usersEvaluationsDay: usersEvaluationsDay,
                      )
                    : HistorySingleUserEvaluationHeader(
                        userEvaluationDay: usersEvaluationsDay[0],
                      ),
              ],
              navigationHeader: Row(
                children: [
                  Text(
                    context.locale.results_screen_results_title,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
              tabs: [
                if (measurementTypes.length > 1) ...{
                  NavigationTabBarItem(
                    label: context.locale.dashboard_screen_all,
                    slivers: [
                      HistoryResultsList(
                        isMultiUser: isMultiUser,
                        historicMeasurements: historicMeasurements,
                      ),
                    ],
                    bottomSlivers: [],
                  ),
                },
                ...measurementTypes
                    .map(
                      (measurementType) => NavigationTabBarItem(
                        label: context.locale.common_measurement_types(
                          measurementType.name,
                        ),
                        slivers: [
                          HistoryResultsList(
                            isMultiUser: isMultiUser,
                            historicMeasurements: historicMeasurements
                                .where(
                                  (measurement) =>
                                      measurement
                                          .carePlan.activity.measurementType ==
                                      measurementType,
                                )
                                .toList(),
                          ),
                        ],
                        bottomSlivers: [],
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BluredScaleAppBar(
              title: date.toRegularDate(),
              subTitle:
                  '${userNames.first}${userNames.length > 1 ? userNames.length - 1 : ''}',
              showClose: true,
              onCloseTap: () {},
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
