import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/dialogs/results_time_dialog.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/scale_card.dart';

class NoResultsInPlansHeader extends StatelessWidget {
  const NoResultsInPlansHeader({
    super.key,
    required this.whenPeriod,
    required this.openWhenSelector,
  });

  final ResultsWhenPeriod whenPeriod;
  final Function openWhenSelector;

  @override
  Widget build(BuildContext context) {
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
                      localization.results_screen_no_results_in_plans(
                        localization.common_measurement_times(whenPeriod.name),
                      ),
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Gaps.gap16,
                  InkWell(
                    onTap: () {
                      openWhenSelector.call();
                    },
                    child: Text(
                      localization.common_measurement_times(whenPeriod.name),
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
