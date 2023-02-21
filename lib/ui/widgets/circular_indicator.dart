import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class CircularIndicator extends StatelessWidget {
  const CircularIndicator({
    super.key,
    required this.label,
    required this.percent,
  });

  final String label;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 18,
      lineWidth: 8,
      //animation: true,
      percent: percent,
      footer: Padding(
        padding: Paddings.top5,
        child: Text(
          label,
          style: ScaleTextStyles.label.copyWith(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      progressColor: Theme.of(context).colorScheme.onError,
    );
  }
}
