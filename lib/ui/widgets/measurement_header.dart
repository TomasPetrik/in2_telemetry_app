import 'package:flutter/material.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class PlannedMeasurementHeader extends StatelessWidget {
  const PlannedMeasurementHeader({
    super.key,
    required this.whenPeriod,
    required this.openTimeSelector,
  });

  final PlanWhenPeriod whenPeriod;
  final Function openTimeSelector;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          Text(
            context.locale.common_measurement,
            style: ScaleTextStyles.textAccent
                .apply(color: Theme.of(context).colorScheme.onSecondary),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              openTimeSelector.call();
            },
            child: Text(
              context.locale.common_measurement_times(whenPeriod.name),
              style: ScaleTextStyles.text.apply(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
