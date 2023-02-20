import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';

class MeasurementItem extends StatelessWidget with BottomSheetMixin {
  const MeasurementItem({
    super.key,
    required this.timingDayWhen,
    required this.carePlan,
    required this.measurementNeed,
  });

  final TimingDayWhen timingDayWhen;
  final CarePlan carePlan;
  final MeasurementNeed measurementNeed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Paddings.all16,
      child: Row(
        children: [
          Text(
            timingDayWhen.start.toString(),
            style: ScaleTextStyles.label.apply(
              color: measurementNeed == MeasurementNeed.now
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.tertiary,
            ),
          ),
          Gaps.gap16,
          SvgPicture.asset(
            measurementNeed == MeasurementNeed.now
                ? 'assets/icons/icon_wave_pulse.svg'
                : 'assets/icons/icon_clock.svg',
            color: measurementNeed == MeasurementNeed.now
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.tertiary,
          ),
          Gaps.gap16,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.locale.common_measurement_types(
                  carePlan.activity.measurementType.name,
                ),
                style: ScaleTextStyles.textAccent.apply(
                  color: measurementNeed == MeasurementNeed.now
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.tertiary,
                ),
              ),
              Gaps.gap6,
              Text(
                context.locale.dashboard_screen_measurement_interval(
                  timingDayWhen.start.toString(),
                  timingDayWhen.end.toString(),
                ),
                style: ScaleTextStyles.label.apply(
                  color: measurementNeed == MeasurementNeed.now
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.tertiary,
                ),
              ),
              if (timingDayWhen.whenCode != null)
                Text(
                  context.locale.common_when_code(timingDayWhen.whenCode!.name),
                  style: ScaleTextStyles.label.apply(
                    color: measurementNeed == MeasurementNeed.now
                        ? Theme.of(context).colorScheme.onSecondary
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ),
            ],
          ),
          if (measurementNeed == MeasurementNeed.now) ...[
            const Spacer(),
            NavigationTabChip(
              label: context.locale.common_measure,
              isSelected: true,
              onTap: () {
                doMeasurement(
                  context: context,
                  userId: carePlan.userId!,
                  selectedMeasurementType: carePlan.activity.measurementType,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

enum MeasurementNeed { now, upcoming }
