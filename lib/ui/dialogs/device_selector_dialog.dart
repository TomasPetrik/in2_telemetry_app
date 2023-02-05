import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_measurement_route.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';

class DeviceSelectorDialog extends StatefulWidget {
  const DeviceSelectorDialog({
    super.key,
    this.selectedActivity,
    this.allActivities,
  }) : assert(
          selectedActivity != null || allActivities != null,
          'Either selectedActivity or allActivities should be not empty !',
        );

  final CarePlanActivity? selectedActivity;
  final Set<CarePlanActivity>? allActivities;

  @override
  State<DeviceSelectorDialog> createState() => _DeviceSelectorDialogState();
}

class _DeviceSelectorDialogState extends State<DeviceSelectorDialog> {
  CarePlanActivity? selectedActivity;
  Set<CarePlanActivity>? allActivities;

  @override
  void initState() {
    allActivities = widget.allActivities;
    selectedActivity = widget.selectedActivity ?? allActivities?.first;

    super.initState();
  }

  String getTitle() {
    String title = context.locale.common_measurement;
    if (selectedActivity != null &&
        (allActivities == null || allActivities?.isEmpty == true)) {
      title +=
          ' ${context.locale.common_measurement_types_genitive(selectedActivity!.measurementType.name).toLowerCase()}';
    }
    return title;
  }

  bool hasMeasurementTabs() {
    return (allActivities != null && allActivities!.length > 1);
  }

  @override
  Widget build(BuildContext context) {
    final session = getIt<Session>();

    final List<Device> supportedDevices = [];

    if (selectedActivity != null) {
      supportedDevices.addAll(
        Constants.supportedDevices.where(
          (device) => device.supportedMeasurementTypes.contains(
            selectedActivity?.measurementType,
          ),
        ),
      );
    }

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
          Text(
            getTitle(),
            style: ScaleTextStyles.textAccent.apply(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          if (hasMeasurementTabs()) ...[
            Gaps.gap24,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...allActivities!
                      .map(
                        (activity) => Row(
                          children: [
                            NavigationTabChip(
                              label: context.locale.common_measurement_types(
                                activity.measurementType.name,
                              ),
                              isSelected: selectedActivity == activity,
                              onTap: () {
                                if (selectedActivity == activity) {
                                  return;
                                }
                                selectedActivity = activity;
                                setState(() {});
                              },
                            ),
                            Gaps.gap8,
                          ],
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
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
          if (session.userAccount!.userPermissions!.contains(
            UserPermission.canManuallyEnterMeasurement,
          )) ...[
            Gaps.gap24,
            HighlightedElevatedButton(
              label: context.locale.common_manual_measurement,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                GoRouter.of(context).pushNamed(
                  ManualMeasurementRoute.name,
                  extra: selectedActivity!.measurementType,
                );
              },
            ),
          ],
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
