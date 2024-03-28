import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/viewModels/measurement_result_view_model.dart';
import 'package:scalesoft_app/ui/widgets/info_placeholder.dart';
import 'package:scalesoft_app/ui/widgets/result_item.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ResultsList extends StatelessWidget {
  const ResultsList({
    super.key,
    required this.dayDt,
    required this.showUserNames,
    required this.mResults,
    this.canOpenChart = false,
  });

  final DateTime dayDt;
  final bool showUserNames;
  final List<MeasurementResultViewModel> mResults;
  final bool canOpenChart;

  List<MeasurementResultViewModel> get _multiDayMeasurements =>
      mResults.where((measurement) => measurement.spansMultipleDays).toList();

  List<MeasurementResultViewModel> get _singleDayMeasurements =>
      mResults.where((measurement) => !measurement.spansMultipleDays).toList();

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
              if (_multiDayMeasurements.isNotEmpty) ...[
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
                          ResultItem(
                            showUserName: showUserNames,
                            viewModel: _multiDayMeasurements[index],
                            canOpenChart: canOpenChart,
                          ),
                          if (index != (_multiDayMeasurements.length - 1) ||
                              (index == (_multiDayMeasurements.length - 1) && _singleDayMeasurements.isNotEmpty))
                            Container(
                              margin: Paddings.horizontal16,
                              height: 0.5,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        ],
                      );
                    },
                    childCount: _multiDayMeasurements.length,
                  ),
                ),
              ],
              if (_singleDayMeasurements.isNotEmpty) ...[
                if (_multiDayMeasurements.isNotEmpty)
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
                            showUserName: showUserNames,
                            viewModel: _singleDayMeasurements[index],
                            canOpenChart: canOpenChart,
                          ),
                          if (index != (_singleDayMeasurements.length - 1))
                            Container(
                              margin: Paddings.horizontal16,
                              height: 0.5,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        ],
                      );
                    },
                    childCount: _singleDayMeasurements.length,
                  ),
                ),
              ],
            ],
          );
  }
}
