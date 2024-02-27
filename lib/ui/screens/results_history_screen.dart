import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/history_multi_user_evaluation_header.dart';
import 'package:scalesoft_app/ui/widgets/history_single_user_evaluation_header.dart';
import 'package:scalesoft_app/ui/widgets/results_list.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

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

    final measurementResults =
        usersEvaluationsDay.fold<List<MeasurementDataContract>>(
      [],
      (previousValue, userEvaluationsDay) => [
        ...previousValue,
        ...userEvaluationsDay.getMeasurementResults(),
      ],
    )..sort(
            (a, b) => b.measurementDateTime.compareTo(a.measurementDateTime),
          );

    final measurementTypes = measurementResults
        .map((measurement) => measurement.measurementType!)
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
                    localization.results_screen_results_title,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
              tabs: [
                if (measurementTypes.length > 1) ...{
                  NavigationTabBarItem(
                    label: localization.dashboard_screen_all,
                    slivers: [
                      ResultsList(
                        dayDt: date,
                        isMultiUser: isMultiUser,
                        mResults: measurementResults,
                      ),
                    ],
                    bottomSlivers: [],
                  ),
                },
                ...measurementTypes
                    .map(
                      (measurementType) => NavigationTabBarItem(
                        label: localization.common_measurement_types(
                          measurementType.name,
                        ),
                        slivers: [
                          ResultsList(
                            dayDt: date,
                            isMultiUser: isMultiUser,
                            mResults: measurementResults
                                .where(
                                  (measurement) =>
                                      measurement.measurementType ==
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
            child: BlurredScaleAppBar(
              title: date.dateFormat,
              subTitle:
                  '${userNames.first}${userNames.length > 1 ? ' ${localization.common_plus_n_others(userNames.length - 1)}' : ''}',
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
