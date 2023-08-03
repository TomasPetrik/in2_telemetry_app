import 'package:flutter/material.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/future_measurement_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:sliver_tools/sliver_tools.dart';

class FutureMeasurementsList extends StatelessWidget {
  const FutureMeasurementsList({
    super.key,
    required this.dayDt,
    required this.isMultiUser,
    required this.futureMeasurements,
  });
  final DateTime dayDt;
  final bool isMultiUser;
  final List<PlannedMeasurement> futureMeasurements;

  List<PlannedMeasurement> get _pMeasurements => futureMeasurements
      .where(
        (measurement) => measurement.isLongPeriod,
      )
      .toList();

  List<PlannedMeasurement> get _rMeasurements => futureMeasurements
      .where(
        (measurement) => !measurement.isLongPeriod,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        if (_pMeasurements.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gaps.gap24,
                Padding(
                  padding: Paddings.left16,
                  child: Text(
                    localization.dashboard_screen_periodical_measurements,
                    style: ScaleTextStyles.label.apply(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                Gaps.gap8,
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureMeasurementItem(
                      isMultiUser: isMultiUser,
                      futureMeasurement: _pMeasurements[index],
                    ),
                    if (index != (_pMeasurements.length - 1) ||
                        (index == (_pMeasurements.length - 1) &&
                            _pMeasurements.isNotEmpty))
                      Container(
                        margin: Paddings.horizontal16,
                        height: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  ],
                );
              },
              childCount: _pMeasurements.length,
            ),
          ),
        ],
        if (_rMeasurements.isNotEmpty) ...[
          if (_pMeasurements.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gaps.gap24,
                  Padding(
                    padding: Paddings.left16,
                    child: Text(
                      dayDt.toRegularDate(),
                      style: ScaleTextStyles.label.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Gaps.gap8,
                ],
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, int index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureMeasurementItem(
                      isMultiUser: isMultiUser,
                      futureMeasurement: _rMeasurements[index],
                    ),
                    if (index != (_rMeasurements.length - 1))
                      Container(
                        margin: Paddings.horizontal16,
                        height: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  ],
                );
              },
              childCount: _rMeasurements.length,
            ),
          ),
        ],
      ],
    );
  }
}
