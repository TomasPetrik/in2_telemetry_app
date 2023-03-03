import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/scale_card.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class CarePlanItem extends StatelessWidget {
  const CarePlanItem({
    super.key,
    required this.carePlan,
  });

  final CarePlan carePlan;

  @override
  Widget build(BuildContext context) {
    return ScaleCard(
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
                Stack(
                  children: [
                    Padding(
                      padding: Paddings.right4,
                      child: SvgPicture.asset(
                        'assets/icons/icon_wave_pulse.svg',
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    if (carePlan.wasChanged == true)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadii.radius4,
                          ),
                        ),
                      ),
                  ],
                ),
                Gaps.gap12,
                Text(
                  context.locale.common_measurement_types(
                    carePlan.activity.measurementType.name,
                  ),
                  style: ScaleTextStyles.textAccent.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(
                  'assets/icons/icon_chart_pie_simple.svg',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            Gaps.gap16,
            Container(
              height: 0.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            Gaps.gap16,
            Text(
              carePlan.author.fullName,
              style: ScaleTextStyles.textAccent.apply(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Gaps.gap6,
            Text(
              carePlan.scheduledEnd != null
                  ? context.locale.user_details_screen_plan_active_from_to_date(
                      carePlan.scheduledStart.toRegularDate(),
                      carePlan.scheduledEnd!.toRegularDate(),
                    )
                  : context.locale.user_details_screen_plan_active_from_date(
                      carePlan.scheduledStart.toRegularDate(),
                    ),
              style: ScaleTextStyles.textAccent.apply(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
