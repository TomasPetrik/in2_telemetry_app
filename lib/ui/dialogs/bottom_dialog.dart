import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';

class BottomDialog extends StatelessWidget {
  const BottomDialog({
    super.key,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.positiveButtonStyle,
    required this.negativeButtonStyle,
  });

  final String title;
  final String description;
  final String iconPath;
  final ButtonStyle? positiveButtonStyle;
  final ButtonStyle? negativeButtonStyle;

  factory BottomDialog.resultConfirmationRemoval({
    Key? key,
    required BuildContext context,
    required MeasurementType measurementType,
  }) {
    return _BottomDialog(
      title: context.locale.result_removal_confirmation_title,
      description: context.locale.result_removal_confirmation_desc(
        context.locale
            .common_measurement_types_genitive(measurementType.name)
            .toLowerCase(),
      ),
      iconPath: 'assets/icons/icon_trash_blank_big.svg',
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.alert,
        label: context.locale.result_removal_confirmation_title_button_confirm,
      ),
      negativeButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: context.locale.common_close,
      ),
    );
  }

  factory BottomDialog.accountConfirmationRemoval({
    Key? key,
    required BuildContext context,
    required String accountName,
  }) {
    return _BottomDialog(
      title: context.locale.dialog_account_removal_confirmation_title,
      description: context.locale
          .dialog_account_removal_confirmation_description(accountName),
      iconPath: 'assets/icons/icon_trash_blank_big.svg',
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.alert,
        label: context
            .locale.dialog_account_removal_confirmation_button_positive_label,
      ),
      negativeButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: context.locale.common_close,
      ),
    );
  }

  factory BottomDialog.serverError({
    Key? key,
    required BuildContext context,
  }) {
    return _BottomDialog(
      title: context.locale.server_error_title,
      description: context.locale.server_error_desc,
      iconPath: 'assets/icons/icon_triangle_exclamation_big.svg',
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: context.locale.common_close,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _BottomDialog(
      title: title,
      description: description,
      iconPath: iconPath,
      positiveButtonStyle: positiveButtonStyle,
      negativeButtonStyle: negativeButtonStyle,
    );
  }
}

class _BottomDialog extends BottomDialog {
  const _BottomDialog({
    required super.title,
    required super.description,
    required super.iconPath,
    super.positiveButtonStyle,
    super.negativeButtonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(RadiusSize.radius16),
          topRight: Radius.circular(RadiusSize.radius16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Gaps.gap34,
          Padding(
            padding: Paddings.horizontal16,
            child: Text(
              title,
              style: ScaleTextStyles.textAccent
                  .apply(color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          Gaps.gap26,
          Center(
            child: SvgPicture.asset(
              iconPath,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          Gaps.gap24,
          Padding(
            padding: Paddings.horizontal64,
            child: Center(
              child: Text(
                description,
                style: ScaleTextStyles.text
                    .apply(color: Theme.of(context).colorScheme.onSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (positiveButtonStyle != null) ...[
            Gaps.gap24,
            Padding(
              padding: Paddings.horizontal16,
              child: HighlightedElevatedButton(
                label: positiveButtonStyle!.label,
                buttonType: positiveButtonStyle!.buttonType,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ],
          if (negativeButtonStyle != null) ...[
            Gaps.gap24,
            Padding(
              padding: Paddings.horizontal16,
              child: HighlightedElevatedButton(
                label: negativeButtonStyle!.label,
                buttonType: negativeButtonStyle!.buttonType,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ),
          ],
          Gaps.gap48,
        ],
      ),
    );
  }
}

class ButtonStyle {
  ButtonType buttonType;
  String label;

  ButtonStyle({
    required this.buttonType,
    required this.label,
  });
}
