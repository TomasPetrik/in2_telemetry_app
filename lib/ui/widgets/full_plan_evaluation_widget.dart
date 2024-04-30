import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/scale_card.dart';
import 'package:scalesoft_app/ui/widgets/single_progress_indicator.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';

class FullPlanEvaluationWidget extends StatelessWidget {
  const FullPlanEvaluationWidget({
    super.key,
    required this.carePlan,
    required this.offlineResults,
  });

  final CarePlan carePlan;
  final List<Measurement> offlineResults;

  @override
  Widget build(BuildContext context) {
    final progress = EvaluationPlanHelper.getProgressFromFullPlanEvaluation(
      carePlan: carePlan,
      offlineResults: offlineResults,
    );

    final veryFirstMeasurement = Calendar.getVeryFirstMeasurement(
      carePlan: carePlan,
    );

    return SliverToBoxAdapter(
      child: Padding(
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
                    Text(
                      localization
                          .care_plan_detail_screen_fulfillment_evaluation,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$progress %',
                      style: ScaleTextStyles.text.apply(
                        color: progress >= 100
                            ? Theme.of(context).colorScheme.onTertiary
                            : progress == 0
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ],
                ),
                if (veryFirstMeasurement.whenEnd.isAfter(DateTime.now())) ...[
                  Gaps.gap6,
                  Text(
                    localization
                        .care_plan_detail_screen_fulfillment_evaluation_valid_from(
                      veryFirstMeasurement.whenStart.toDateOrDay(),
                      veryFirstMeasurement.whenStart.timeFormatShort,
                    ),
                    style: ScaleTextStyles.label.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ],
                Gaps.gap16,
                SingleProgressIndicator(
                  progress: progress,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
