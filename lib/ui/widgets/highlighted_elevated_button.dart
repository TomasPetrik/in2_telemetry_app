import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/dark_mode.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class HighlightedElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final ButtonType buttonType;

  const HighlightedElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.buttonType = ButtonType.primary,
    this.icon,
  });

  Color _getColorByType(BuildContext context) {
    switch (buttonType) {
      case ButtonType.primary:
        return Theme.of(context).colorScheme.onSurface;
      case ButtonType.secondary:
        return Theme.of(context).colorScheme.onPrimary;
      case ButtonType.alert:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = buttonType == ButtonType.primary
        ? Theme.of(context).primaryColor
        : buttonType == ButtonType.secondary
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.error;

    return SizedBox(
      height: Dimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: DarkMode.elevatedButtonStyle.copyWith(
          padding: MaterialStateProperty.all<EdgeInsets>(
            EdgeInsets.zero,
          ),
          backgroundColor: MaterialStateColor.resolveWith(
            (states) =>
                states.isNotEmpty && states.first == MaterialState.pressed
                    ? backgroundColor.withOpacity(0.5)
                    : backgroundColor,
          ),
        ),
        child: Ink(
          padding: EdgeInsets.zero,
          height: Dimensions.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadii.radius8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: buttonType == ButtonType.primary
                    ? ScaleTextStyles.textAccent
                        .apply(color: _getColorByType(context))
                    : ScaleTextStyles.textAccent
                        .apply(color: _getColorByType(context)),
              ),
            ],
          ),
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
