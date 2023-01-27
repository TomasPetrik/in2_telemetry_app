import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/fulfillment_evaluation_widget.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/sliver_name_value_row.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class CarePlanDetailScreen extends StatelessWidget {
  const CarePlanDetailScreen({
    super.key,
    required this.carePlan,
  });

  final CarePlan carePlan;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverGap(
                MediaQuery.of(context).viewPadding.top + Constants.appBarHeight,
              ),
              const SliverGap(Dimensions.padding24),
              if (carePlan.fulfillmentEvaluation != null)
                FulfillmentEvaluationWidget(
                  fulfillmentEvaluation: carePlan.fulfillmentEvaluation!,
                ),
              const SliverGap(Dimensions.padding42),
              SliverPadding(
                padding: Paddings.left16,
                sliver: SliverToBoxAdapter(
                  child: Text(
                    context.locale.care_plan_detail_screen_plan_info,
                    style: ScaleTextStyles.textAccent.apply(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ),
              const SliverGap(Dimensions.padding26),
              SliverNameValueRow(
                name: context.locale.care_plan_detail_screen_managed_by,
                value: carePlan.author.fullName,
              ),
              const SliverGap(Dimensions.padding8),
              SliverNameValueRow(
                name: context.locale.care_plan_detail_screen_active_from_date,
                value: carePlan.scheduledStart.toRegularDate(),
              ),
              if (carePlan.scheduledEnd != null) ...[
                const SliverGap(Dimensions.padding8),
                SliverNameValueRow(
                  name: context.locale.care_plan_detail_screen_active_to_date,
                  value: carePlan.scheduledEnd!.toRegularDate(),
                ),
              ],
              const SliverGap(Dimensions.padding8),
              SliverNameValueRow(
                name: context.locale.care_plan_detail_screen_measurement,
                value: context.locale.common_measurement_types(
                  carePlan.activity.measurementType.name,
                ),
              ),
              const SliverGap(Dimensions.padding26),
              SliverToBoxAdapter(
                child: Padding(
                  padding: Paddings.horizontal16,
                  child: HighlightedElevatedButton(
                    label: context.locale.care_plan_detail_screen_show_calendar,
                    buttonType: ButtonType.primary,
                    onPressed: () async {},
                  ),
                ),
              ),
              const SliverGap(Dimensions.padding42),
              SliverPadding(
                padding: Paddings.horizontal16,
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.locale.care_plan_detail_daily_times,
                        style: ScaleTextStyles.textAccent.apply(
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/icon_dots_horizontal.svg',
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ],
                  ),
                ),
              ),
              const SliverGap(Dimensions.padding26),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScaleAppBar(
              title: context.locale.common_measurement_types(
                carePlan.activity.measurementType.name,
              ),
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
