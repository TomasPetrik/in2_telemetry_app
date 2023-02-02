import 'package:flutter/material.dart';
import 'package:scalesoft_app/ui/dialogs/popup_dialog.dart';
import 'package:scalesoft_app/ui/dialogs/popup_error.dart';
import 'package:scalesoft_app/utils/scale_colors.dart';

mixin PopupDialogMixin {
  Future<void> showPopup(
    final BuildContext context, {
    required String message,
    Widget? icon,
    Duration? hideAfter = const Duration(seconds: 3),
    Function? afterHideAction,
  }) async {
    bool popupIsActive = true;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (context) => PopupDialog(
        icon: icon,
        message: message,
        onCancel: () {
          popupIsActive = false;
          afterHideAction != null ? afterHideAction() : null;
        },
      ),
    );

    if (hideAfter != null) {
      Future.delayed(hideAfter, () {
        if (popupIsActive) {
          Navigator.of(context).pop();
          afterHideAction != null ? afterHideAction() : null;
        }
      });
    }
  }

  Future<void> showError(
    final BuildContext context, {
    required String message,
    Duration? hideAfter = const Duration(seconds: 3),
    Function? afterHideAction,
  }) async {
    bool popupIsActive = true;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (context) => PopupError(
        icon: const Icon(
          Icons.error_outline,
          size: 40,
          color: ScaleColors.white,
        ),
        message: message,
        onCancel: () {
          popupIsActive = false;
          afterHideAction != null ? afterHideAction() : null;
        },
      ),
    );

    if (hideAfter != null) {
      Future.delayed(hideAfter, () {
        if (popupIsActive) {
          Navigator.of(context).pop();
          afterHideAction != null ? afterHideAction() : null;
        }
      });
    }
  }
}
