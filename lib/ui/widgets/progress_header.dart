import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/circular_indicator.dart';
import 'package:scalesoft_app/ui/widgets/single_progress_indicator.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.whenPeriod,
    required this.openWhenSelector,
    required this.progressItems,
  });

  final ResultsWhenPeriod whenPeriod;
  final Function openWhenSelector;
  final List<ProgressItem> progressItems;

  @override
  Widget build(BuildContext context) {
    final itemWidth =
        (MediaQuery.of(context).size.width - (4 * Dimensions.padding16)) / 4;

    return SliverToBoxAdapter(
      child: Padding(
        padding: Paddings.horizontal16,
        child: Card(
          child: Container(
            width: double.maxFinite,
            padding: Paddings.all16,
            decoration: BoxDecoration(
              borderRadius: BorderRadii.radius16,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/icon_chart_pie_simple.svg',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    Gaps.gap16,
                    Text(
                      context.locale.common_plan_fulfillment,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        openWhenSelector.call();
                      },
                      child: Text(
                        context.locale
                            .common_measurement_times(whenPeriod.name),
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Gaps.gap16,
                if (progressItems.length == 1) ...{
                  Builder(
                    builder: (context) {
                      return SingleProgressIndicator(
                        progress: progressItems.first.progress,
                      );
                    },
                  )
                } else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...progressItems
                            .map(
                              (progressItem) => SizedBox(
                                width: itemWidth,
                                child: CircularIndicator(
                                  label: progressItem.label,
                                  percent: progressItem.progress / 100,
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressItem {
  final String label;
  final int progress;

  const ProgressItem(this.label, this.progress);
}
