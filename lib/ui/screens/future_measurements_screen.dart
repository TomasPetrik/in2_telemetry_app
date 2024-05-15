import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/navigation_screen.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/future_measurements_list.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class FutureMeasurementsScreen extends StatelessWidget {
  FutureMeasurementsScreen({
    super.key,
    required this.results,
  }) : assert(
          results.isNotEmpty,
          'To show future page must be included at least one evaluation day !',
        );

  final List<MeasurementResultViewModel> results;

  @override
  Widget build(BuildContext context) {
    final date = results.first.measurementTime;
    final users = results.map((evDay) => evDay.user);

    final bool showUserNames = users.length > 1;

    final futureMeasurements = results.sortedBy((x)=>x.measurementTime).toList();

    final measurementTypes = futureMeasurements.map((measurement) => measurement.measurementType).toSet();

    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: NavigationScreen(
              navigationHeader: Row(
                children: [
                  Text(
                    localization.common_measurement,
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
                      FutureMeasurementsList(
                        dayDt: date,
                        showUserNames: showUserNames,
                        futureMeasurements: futureMeasurements,
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
                          FutureMeasurementsList(
                            dayDt: date,
                            showUserNames: showUserNames,
                            futureMeasurements: futureMeasurements
                                .where(
                                  (measurement) => measurement.measurementType == measurementType,
                                )
                                .toList(),
                          ),
                        ],
                        bottomSlivers: [],
                      ),
                    )
                    ,
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
                  '${users.first.fullName}${users.length > 1 ? ' ${localization.common_plus_n_others(users.length - 1)}' : ''}',
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
