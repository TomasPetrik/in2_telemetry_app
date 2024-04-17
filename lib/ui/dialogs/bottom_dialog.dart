import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';

class BottomDialog extends StatelessWidget {
  const BottomDialog({
    super.key,
    this.title,
    required this.description,
    required this.iconPath,
    required this.iconColor,
    required this.positiveButtonStyle,
    required this.negativeButtonStyle,
  });

  final String? title;
  final String description;
  final String iconPath;
  final Color iconColor;
  final ButtonStyle? positiveButtonStyle;
  final ButtonStyle? negativeButtonStyle;

  factory BottomDialog.resultConfirmationRemoval({
    Key? key,
    required BuildContext context,
    required MeasurementType measurementType,
  }) {
    return _BottomDialog(
      title: localization.result_removal_confirmation_title,
      description: localization.result_removal_confirmation_desc(
        localization
            .common_measurement_types_genitive(measurementType.name)
            .toLowerCase(),
      ),
      iconPath: 'assets/icons/icon_trash_blank_big.svg',
      iconColor: Theme.of(context).colorScheme.tertiary,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.alert,
        label: localization.result_removal_confirmation_title_button_confirm,
      ),
      negativeButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }

  factory BottomDialog.openNotificationSettings({
    Key? key,
    required BuildContext context,
  }) {
    return _BottomDialog(
      title: localization.dialog_req_notifications_title,
      description: localization.dialog_req_notifications_description,
      iconPath: 'assets/icons/icon_triangle_exclamation_big.svg',
      iconColor: Theme.of(context).colorScheme.tertiary,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.primary,
        label: localization.dialog_req_notifications_go_to_settings,
      ),
      negativeButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }

  factory BottomDialog.openLocalizationSettings({
    Key? key,
    required BuildContext context,
  }) {
    return _BottomDialog(
      title: localization.dialog_req_localization_service_title,
      description: localization.dialog_req_localization_service_description,
      iconPath: 'assets/icons/icon_triangle_exclamation_big.svg',
      iconColor: Theme.of(context).colorScheme.tertiary,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.primary,
        label: localization.dialog_req_localization_service_go_to_settings,
      ),
      negativeButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }

  factory BottomDialog.deviceConfirmationRemoval({
    Key? key,
    required BuildContext context,
  }) {
    return _BottomDialog(
      title: localization.metering_screen_device_removal_title,
      description: localization.metering_screen_device_removal_message,
      iconPath: 'assets/icons/icon_trash_blank_big.svg',
      iconColor: Theme.of(context).colorScheme.tertiary,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.alert,
        label: localization.metering_screen_device_removal_button_confirm,
      ),
      negativeButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }

  factory BottomDialog.accountConfirmationRemoval({
    Key? key,
    required BuildContext context,
    required String accountName,
  }) {
    return _BottomDialog(
      title: localization.dialog_account_removal_confirmation_title,
      description: localization
          .dialog_account_removal_confirmation_description(accountName),
      iconPath: 'assets/icons/icon_trash_blank_big.svg',
      iconColor: Theme.of(context).colorScheme.tertiary,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.alert,
        label: localization.dialog_account_removal_confirmation_title,
      ),
      negativeButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }

  factory BottomDialog.resetWhenTimeValues({
    Key? key,
    required BuildContext context,
  }) {
    return _BottomDialog(
      title: localization.daily_when_time_reset_confirmation_title,
      description: localization.daily_when_time_reset_confirmation_info,
      iconPath: 'assets/icons/icon_clock_big.svg',
      iconColor: Theme.of(context).colorScheme.tertiary,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.primary,
        label: localization.daily_when_time_reset_confirmation_confirm,
      ),
      negativeButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }

  factory BottomDialog.serverError({
    Key? key,
    required BuildContext context,
  }) {
    return _BottomDialog(
      title: localization.server_error_title,
      description: localization.server_error_desc,
      iconPath: 'assets/icons/icon_triangle_exclamation_big.svg',
      iconColor: Theme.of(context).colorScheme.error,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }

  factory BottomDialog.deviceAlreadyRegistered({
    Key? key,
    required BuildContext context,
    required String macAddress,
  }) {
    return _BottomDialog(
      title: localization.register_device_detail_registration_fail_title,
      description: localization
          .register_device_detail_registration_fail_message(macAddress),
      iconPath: 'assets/icons/icon_triangle_exclamation_big.svg',
      iconColor: Theme.of(context).colorScheme.error,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }

  factory BottomDialog.deviceNotFound({
    Key? key,
    required BuildContext context,
  }) {
    return _BottomDialog(
      title: localization.find_device_not_found_title,
      description: localization.find_device_not_found_desc,
      iconPath: 'assets/icons/icon_triangle_exclamation_big.svg',
      iconColor: Theme.of(context).colorScheme.error,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.primary,
        label: localization.find_device_repeat_search,
      ),
      negativeButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }

  factory BottomDialog.reportsSent({
    Key? key,
    required BuildContext context,
  }) {
    return _BottomDialog(
      title: '',
      description: localization.user_detail_screen_debug_logs_sent,
      iconPath: 'assets/icons/icon_circle_check_big.svg',
      iconColor: Theme.of(context).colorScheme.onTertiary,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }

  factory BottomDialog.watchSetupFailed({
    Key? key,
    required BuildContext context,
  }) {
    return _BottomDialog(
      title: localization.server_error_title,
      description: localization.watch_setup_failed,
      iconPath: 'assets/icons/icon_triangle_exclamation_big.svg',
      iconColor: Theme.of(context).colorScheme.error,
      positiveButtonStyle: ButtonStyle(
        buttonType: ButtonType.secondary,
        label: localization.common_close,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return _BottomDialog(
      title: title,
      description: description,
      iconPath: iconPath,
      iconColor: iconColor,
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
    required super.iconColor,
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
          if (title?.isNotEmpty == true) ...[
            Padding(
              padding: Paddings.horizontal16,
              child: Text(
                title!,
                style: ScaleTextStyles.textAccent
                    .apply(color: Theme.of(context).colorScheme.onSecondary),
              ),
            ),
            Gaps.gap26,
          ],
          Center(
            child: SvgPicture.asset(
              iconPath,
              color: iconColor,
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
