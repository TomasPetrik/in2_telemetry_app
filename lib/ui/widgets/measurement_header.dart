import 'package:flutter/material.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class MeasurementHeader extends StatelessWidget {
  const MeasurementHeader({
    super.key,
    required this.measurementTime,
  });

  final MeasurementTime measurementTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          context.locale.common_measurement,
          style: ScaleTextStyles.textAccent.apply(color: Theme.of(context).colorScheme.onSecondary),
        ),
        const Spacer(),
        Text(
          context.locale.common_measurement_times(measurementTime.name),
          style: ScaleTextStyles.text.apply(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}

enum MeasurementTime {
  today,
  upcomming,
  tomorrow,
}
