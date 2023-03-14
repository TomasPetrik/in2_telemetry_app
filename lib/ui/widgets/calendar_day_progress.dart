import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

class CalendarDayProgress extends StatelessWidget {
  const CalendarDayProgress({
    super.key,
    required this.progress,
  });

  final int? progress;

  @override
  Widget build(BuildContext context) {
    final mProgress = progress ?? 0;
    int? sideFlex;
    if (mProgress < 100) {
      sideFlex = (100 - mProgress) ~/ 2;
    }
    return ClipRRect(
      borderRadius: BorderRadii.radius2,
      child: Container(
        width: 20,
        height: 4,
        color: Theme.of(context).colorScheme.secondary,
        child: Row(
          children: [
            if (sideFlex != null && sideFlex > 0)
              Spacer(
                flex: sideFlex,
              ),
            Expanded(
              flex: mProgress,
              child: ClipRRect(
                borderRadius: BorderRadii.radius2,
                child: Container(
                  color: mProgress >= 100
                      ? Theme.of(context).colorScheme.onTertiary
                      : Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
            if (sideFlex != null && sideFlex > 0)
              Spacer(
                flex: sideFlex,
              ),
          ],
        ),
      ),
    );
  }
}
