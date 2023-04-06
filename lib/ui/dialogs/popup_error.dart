import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/utils/scale_colors.dart';

// todo: change this when design for errors is done
class PopupError extends StatelessWidget {
  const PopupError({
    Key? key,
    required this.message,
    required this.icon,
    this.onCancel,
  }) : super(key: key);

  final String message;
  final Widget icon;
  final VoidCallback? onCancel;

  @override
  Widget build(final BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: Paddings.all16,
              padding: Paddings.all12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadii.radius20,
              ),
              child: Row(
                children: [
                  icon,
                  Gaps.gap10,
                  Expanded(
                    child: Text(
                      message,
                      style: ScaleTextStyles.label.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Gaps.gap10,
                  IconButton(
                    onPressed: () {
                      onCancel?.call();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.cancel,
                      color: ScaleColors.white,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
