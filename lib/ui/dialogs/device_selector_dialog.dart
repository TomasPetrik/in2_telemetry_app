import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';

class DeviceSelectorDialog extends StatelessWidget {
  const DeviceSelectorDialog({
    super.key,
    required this.carePlanActivity,
  });

  final CarePlanActivity carePlanActivity;

  @override
  Widget build(BuildContext context) {
    final session = getIt<Session>();

    final supportedDevices = Constants.devices.where(
      (device) => device.supportedMeasurementTypes.contains(
        carePlanActivity.measurementType,
      ),
    );

    return Container(
      padding: Paddings.horizontal16,
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
          Gaps.gap24,
          Row(
            children: [
              Text(
                context.locale.measurement_dialog_title(
                  context.locale.common_measurement_types(
                    carePlanActivity.measurementType.name,
                  ),
                ),
                style: ScaleTextStyles.textAccent.apply(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              if (session.userAccount!.userPermissions!.contains(
                UserPermission.canManuallyEnterMeasurement,
              )) ...{
                const Spacer(),
                Text(
                  context.locale.common_manually,
                  style: ScaleTextStyles.text
                      .apply(color: Theme.of(context).colorScheme.primary),
                ),
              }
            ],
          ),
          ...supportedDevices
              .map(
                (supportedDevice) => Container(
                  padding: Paddings.top24,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadii.radius8,
                        child: Container(
                          color: Theme.of(context).colorScheme.onPrimary,
                          height: 128,
                          width: 128,
                          child: Image.asset(supportedDevice.imagePath),
                        ),
                      ),
                      Gaps.gap16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              supportedDevice.modelName ?? '',
                              style: ScaleTextStyles.text.apply(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            Gaps.gap6,
                            Text(
                              context.locale.measurement_dialog_device_desc(
                                supportedDevice.deviceModel.name,
                              ),
                              style: ScaleTextStyles.label.apply(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          Gaps.gap24,
          HighlightedElevatedButton(
            label: context.locale.common_close,
            buttonType: ButtonType.secondary,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Gaps.gap48,
        ],
      ),
    );
  }
}
