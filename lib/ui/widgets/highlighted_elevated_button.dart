import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/dark_mode.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class HighlightedElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final ButtonType buttonType;

  const HighlightedElevatedButton({
    super.key,
    this.onPressed,
    required this.label,
    this.buttonType = ButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = buttonType == ButtonType.primary
        ? Theme.of(context).primaryColor
        : buttonType == ButtonType.secondary
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.error;

    return ElevatedButton(
      onPressed: onPressed,
      style: DarkMode.elevatedButtonStyle.copyWith(
        backgroundColor: MaterialStateColor.resolveWith(
          (states) => states.isNotEmpty && states.first == MaterialState.pressed
              ? backgroundColor.withOpacity(0.5)
              : backgroundColor,
        ),
      ),
      child: Ink(
        height: Constants.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadii.radius8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              Gaps.gap10,
            ],
            Text(
              label,
              style: ScaleTextStyles.textAccent
                  .apply(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

enum ButtonType {
  primary,
  secondary,
  alert,
}
