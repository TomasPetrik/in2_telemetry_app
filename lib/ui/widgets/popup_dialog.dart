import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class PopupDialog extends StatelessWidget {
  const PopupDialog({
    Key? key,
    required this.message,
    required this.icon,
    this.onCancel,
  }) : super(key: key);

  final String message;
  final Widget? icon;
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
                color: ScaleColors.white,
                borderRadius: BorderRadii.radius20,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ScaleColors.white,
                    ScaleColors.blurDark1,
                  ],
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...{icon!},
                  Gaps.gap10,
                  Expanded(
                    child: Text(
                      key: const Key('send_forgot_password_popup'),
                      message,
                      style: ScaleTextStyles.heading4.apply(color: ScaleColors.blurDark1),
                    ),
                  ),
                  Gaps.gap10,
                  IconButton(
                    onPressed: () {
                      onCancel?.call();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.cancel),
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
