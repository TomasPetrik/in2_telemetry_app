import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class ResultItem extends StatelessWidget with BottomSheetMixin {
  const ResultItem({
    super.key,
    required this.mResult,
  });

  final MeasurementResult mResult;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Paddings.all16,
      child: Row(
        children: [
          Text(
            mResult.measurementFinishDateTime?.toTimeOfDay().toString() ??
                mResult.measurementDateTime.toTimeOfDay().toString(),
            style: ScaleTextStyles.label.apply(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          Gaps.gap16,
          SvgPicture.asset(
            'assets/icons/icon_wave_pulse.svg',
            color: mResult.wasMeasured == false
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onTertiary,
          ),
          Gaps.gap16,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.locale.common_measurement_types(
                  mResult.measurementType!.name,
                ),
                style: ScaleTextStyles.textAccent.apply(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              if (mResult.wasMeasured == false &&
                  mResult.measurementFinishDateTime != null) ...[
                Gaps.gap6,
                Text(
                  context.locale.dashboard_screen_measurement_interval(
                    mResult.measurementDateTime.toTimeOfDay().toString(),
                    mResult.measurementFinishDateTime!.toTimeOfDay().toString(),
                  ),
                  style: ScaleTextStyles.label.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ]
            ],
          ),
          if (mResult.wasMeasured == false) ...[
            const Spacer(),
            Text(
              context.locale.common_not_measured,
              style: ScaleTextStyles.text
                  .apply(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

enum MeasurementNeed { now, upcoming }
