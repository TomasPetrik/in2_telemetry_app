import 'package:flutter/material.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/ui/widgets/future_measurement_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:sliver_tools/sliver_tools.dart';

class FutureMeasurementsList extends StatelessWidget {
  const FutureMeasurementsList({
    super.key,
    required this.dayDt,
    required this.showUserNames,
    required this.futureMeasurements,
  });

  final DateTime dayDt;
  final bool showUserNames;
  final List<MeasurementResultViewModel> futureMeasurements;

  List<MeasurementResultViewModel> get multiDayMeasurements => futureMeasurements
      .where(
        (measurement) => measurement.spansMultipleDays,
      )
      .toList();

  List<MeasurementResultViewModel> get singleDayMeasurements => futureMeasurements
      .where(
        (measurement) => !measurement.spansMultipleDays,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        if (multiDayMeasurements.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gaps.gap24,
                Padding(
                  padding: Paddings.left16,
                  child: Text(
                    localization.multi_day_measurements,
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
                      showUserName: showUserNames,
                      measurement: multiDayMeasurements[index],
                    ),
                    if (index != (multiDayMeasurements.length - 1) ||
                        (index == (multiDayMeasurements.length - 1) && multiDayMeasurements.isNotEmpty))
                      Container(
                        margin: Paddings.horizontal16,
                        height: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  ],
                );
              },
              childCount: multiDayMeasurements.length,
            ),
          ),
        ],
        if (singleDayMeasurements.isNotEmpty) ...[
          if (multiDayMeasurements.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gaps.gap24,
                  Padding(
                    padding: Paddings.left16,
                    child: Text(
                      dayDt.dateFormat,
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
                      showUserName: showUserNames,
                      measurement: singleDayMeasurements[index],
                    ),
                    if (index != (singleDayMeasurements.length - 1))
                      Container(
                        margin: Paddings.horizontal16,
                        height: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  ],
                );
              },
              childCount: singleDayMeasurements.length,
            ),
          ),
        ],
      ],
    );
  }
}
