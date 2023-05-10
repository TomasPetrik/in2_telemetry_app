import 'package:flutter/material.dart';
import 'package:scalesoft_app/bloc/calendar/calendar_bloc_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/future_measurements_list.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class FutureMeasurementsScreen extends StatelessWidget {
  FutureMeasurementsScreen({
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

    final futureMeasurements =
        usersEvaluationsDay.fold<List<PlannedMeasurement>>(
      [],
      (previousValue, userEvaluationsDay) => [
        ...previousValue,
        ...userEvaluationsDay.getFutureMeasurements(),
      ],
    )..sort(
            (a, b) => b.whenStart.compareTo(a.whenStart),
          );

    final measurementTypes = futureMeasurements
        .map((measurement) => measurement.carePlan.activity.measurementType)
        .toSet();

    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: NavigationScreen(
              navigationHeader: Row(
                children: [
                  Text(
                    translactions.common_measurement,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
              tabs: [
                if (measurementTypes.length > 1) ...{
                  NavigationTabBarItem(
                    label: translactions.dashboard_screen_all,
                    slivers: [
                      FutureMeasurementsList(
                        dayDt: date,
                        isMultiUser: isMultiUser,
                        futureMeasurements: futureMeasurements,
                      ),
                    ],
                    bottomSlivers: [],
                  ),
                },
                ...measurementTypes
                    .map(
                      (measurementType) => NavigationTabBarItem(
                        label: translactions.common_measurement_types(
                          measurementType.name,
                        ),
                        slivers: [
                          FutureMeasurementsList(
                            dayDt: date,
                            isMultiUser: isMultiUser,
                            futureMeasurements: futureMeasurements
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
                  '${userNames.first}${userNames.length > 1 ? ' ${translactions.common_plus_n_others(userNames.length - 1)}' : ''}',
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
