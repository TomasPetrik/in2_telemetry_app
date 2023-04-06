import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class SingleProgressIndicator extends StatelessWidget {
  const SingleProgressIndicator({
    super.key,
    required this.progress,
    this.label,
  });

  final int progress;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadii.radius4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 8,
            color: Theme.of(context).colorScheme.secondary,
            child: Row(
              children: [
                Expanded(
                  flex: progress,
                  child: ClipRRect(
                    borderRadius: BorderRadii.radius4,
                    child: Container(
                      color: progress >= 100
                          ? Theme.of(context).colorScheme.onTertiary
                          : Theme.of(context).colorScheme.onError,
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
          if (label != null)
            Padding(
              padding: Paddings.top5,
              child: Text(
                label!,
                style: ScaleTextStyles.label.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
