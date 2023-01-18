import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';

class PopupDialog extends StatelessWidget {
  const PopupDialog({
    super.key,
    required this.message,
    this.icon,
    this.onCancel,
  });

  final String message;
  final Widget? icon;
  final VoidCallback? onCancel;

  factory PopupDialog.loading({
    required String message,
  }) {
    return _LoadingDialog(message: message);
  }

  @override
  Widget build(final BuildContext context) {
    return _PopupDialog(
      message: message,
      icon: icon,
    );
  }
}

class _PopupDialog extends PopupDialog {
  const _PopupDialog({
    required super.message,
    required super.icon,
  });

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
                color: ScaleColorsLight.paper,
                borderRadius: BorderRadii.radius20,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ScaleColorsLight.paper,
                    ScaleColorsLight.content100,
                  ],
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...{icon!},
                  Gaps.gap10,
                  Expanded(
                    child: Text(
                      message,
                      style: ScaleTextStyles.label
                          .apply(color: ScaleColorsLight.content100),
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

class _LoadingDialog extends PopupDialog {
  const _LoadingDialog({
    required super.message,
  });

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
                borderRadius: BorderRadii.radius16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Gaps.gap10,
                  Text(
                    message,
                    style: ScaleTextStyles.label
                        .apply(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  Gaps.gap10,
                  const LoadingIndicator(),
                  Gaps.gap10,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
