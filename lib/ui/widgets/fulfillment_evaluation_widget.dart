import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/care_plan/fulfillment_evaluation.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/utils/helpers/evaluation_plan_helper.dart';

class FulfillmentEvaluationWidget extends StatelessWidget {
  const FulfillmentEvaluationWidget({
    super.key,
    required this.fulfillmentEvaluation,
  });

  final FulfillmentEvaluation fulfillmentEvaluation;

  @override
  Widget build(BuildContext context) {
    int progress =
        EvaluationPlanHelper.getProgressFromEvaluation(fulfillmentEvaluation);
    return SliverToBoxAdapter(
      child: Container(
        margin: Paddings.horizontal16,
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
                  context.locale.care_plan_detail_screen_fulfillment_evaluation,
                  style: ScaleTextStyles.text.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$progress %',
                  style: ScaleTextStyles.text.apply(
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ],
            ),
            Gaps.gap16,
            ClipRRect(
              borderRadius: BorderRadii.radius4,
              child: Container(
                height: 8,
                color: Theme.of(context).colorScheme.secondary,
                child: Row(
                  children: [
                    Expanded(
                      flex: progress,
                      child: ClipRRect(
                        borderRadius: BorderRadii.radius4,
                        child: Container(
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ),
                    Spacer(
                      flex: 100 - progress,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
