import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

class SinglePlanFullEvaluationProgressIndicator extends StatelessWidget {
  const SinglePlanFullEvaluationProgressIndicator({
    super.key,
    required this.progress,
  });

  final int progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
            if (progress < 100)
              Spacer(
                flex: 100 - progress,
              ),
          ],
        ),
      ),
    );
  }
}
