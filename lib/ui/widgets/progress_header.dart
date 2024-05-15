import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/circular_indicator.dart';
import 'package:scalesoft_app/ui/widgets/scale_card.dart';
import 'package:scalesoft_app/ui/widgets/single_progress_indicator.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    this.whenPeriod,
    this.openWhenSelector,
    required this.progressItems,
    required this.label,
  });

  final ResultsWhenPeriod? whenPeriod;
  final Function? openWhenSelector;
  final List<ProgressItem> progressItems;
  final String label;

  @override
  Widget build(BuildContext context) {
    int parts = (progressItems.length < 5 ? progressItems.length : 5);

    var itemWidth = (MediaQuery.of(context).size.width - (4 * Dimensions.padding16)) / parts;

    if (parts > 4) {
      itemWidth *= 1.15;
    }

    ScrollController scrollController = ScrollController(
      initialScrollOffset: parts > 4 ? Dimensions.padding16 : 0,
    );

    return Padding(
      padding: Paddings.horizontal16,
      child: ScaleCard(
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
                  Expanded(
                    child: Text(
                      label,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  if (whenPeriod != null && openWhenSelector != null) ...[
                    Gaps.gap16,
                    InkWell(
                      onTap: () {
                        openWhenSelector?.call();
                      },
                      child: Text(
                        localization.common_measurement_times(whenPeriod!.name),
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Gaps.gap16,
              if (progressItems.length == 1) ...{
                Builder(
                  builder: (context) {
                    return SingleProgressIndicator(
                      progress: progressItems.first.progress,
                      label: progressItems.first.label,
                    );
                  },
                ),
              } else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: scrollController,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...progressItems.map(
                        (progressItem) => SizedBox(
                          width: itemWidth,
                          child: Padding(
                            padding: Paddings.horizontal4,
                            child: CircularIndicator(
                              label: progressItem.label,
                              percent: progressItem.progress / 100,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
