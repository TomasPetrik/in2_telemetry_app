import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/info_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/result_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ResultsList extends StatelessWidget {
  const ResultsList({
    super.key,
    required this.dayDt,
    required this.isMultiUser,
    required this.mResults,
    this.canOpenChart = false,
  });

  final DateTime dayDt;
  final bool isMultiUser;
  final List<MeasurementResult> mResults;
  final bool canOpenChart;

  List<MeasurementResult> get _longPeriodicalNotCompletedMeasurements =>
      mResults
          .where(
            (measurement) =>
                measurement.isLongPeriod && !measurement.wasMeasured,
          )
          .toList();

  List<MeasurementResult> get _rMeasurements => mResults
      .where(
        (measurement) =>
            !(measurement.isLongPeriod && !measurement.wasMeasured),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return mResults.isEmpty
        ? SliverPadding(
            padding: Paddings.horizontal64,
            sliver: InfoPlaceholder(
              icon: SvgPicture.asset(
                'assets/icons/icon_chart_pie_simple_big.svg',
                color: Theme.of(context).colorScheme.tertiary,
              ),
              label: dayDt.toHistoricalDateOrDay(),
            ),
          )
        : MultiSliver(
            children: [
              if (_longPeriodicalNotCompletedMeasurements.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gaps.gap24,
                      Padding(
                        padding: Paddings.left16,
                        child: Text(
                          localization
                              .dashboard_screen_periodical_measurements,
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
                          ResultItem(
                            isMultiUser: isMultiUser,
                            mResult:
                                _longPeriodicalNotCompletedMeasurements[index],
                            canOpenChart: canOpenChart,
                          ),
                          if (index !=
                                  (_longPeriodicalNotCompletedMeasurements
                                          .length -
                                      1) ||
                              (index ==
                                      (_longPeriodicalNotCompletedMeasurements
                                              .length -
                                          1) &&
                                  _rMeasurements.isNotEmpty))
                            Container(
                              margin: Paddings.horizontal16,
                              height: 0.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        ],
                      );
                    },
                    childCount: _longPeriodicalNotCompletedMeasurements.length,
                  ),
                ),
              ],
              if (_rMeasurements.isNotEmpty) ...[
                if (_longPeriodicalNotCompletedMeasurements.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gaps.gap24,
                        Padding(
                          padding: Paddings.left16,
                          child: Text(
                            dayDt.toDateOrDay(),
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
                          ResultItem(
                            isMultiUser: isMultiUser,
                            mResult: _rMeasurements[index],
                            canOpenChart: canOpenChart,
                          ),
                          if (index != (_rMeasurements.length - 1))
                            Container(
                              margin: Paddings.horizontal16,
                              height: 0.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
