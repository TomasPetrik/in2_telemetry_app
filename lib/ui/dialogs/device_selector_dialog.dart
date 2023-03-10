import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_measurement_route.dart';
import 'package:scalesoft_app/ui/routers/routes/omron_flow_route.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';

class DeviceSelectorDialog extends StatefulWidget {
  const DeviceSelectorDialog({
    super.key,
    required this.userId,
    this.selectedMeasurementType,
    required this.allMeasurementTypes,
  }) : assert(
          selectedMeasurementType != null ||
              (allMeasurementTypes != null && allMeasurementTypes.length > 0),
          'Either selectedActivity or allActivities should be not empty !',
        );

  final String userId;
  final MeasurementType? selectedMeasurementType;
  final Set<MeasurementType>? allMeasurementTypes;

  @override
  State<DeviceSelectorDialog> createState() => _DeviceSelectorDialogState();
}

class _DeviceSelectorDialogState extends State<DeviceSelectorDialog> {
  MeasurementType? selectedMeasurementType;
  Set<MeasurementType>? allMeasurementTypes;

  @override
  void initState() {
    allMeasurementTypes = widget.allMeasurementTypes;
    selectedMeasurementType =
        widget.selectedMeasurementType ?? allMeasurementTypes?.first;

    super.initState();
  }

  String getTitle() {
    String title = context.locale.common_measurement;
    if (selectedMeasurementType != null &&
        (allMeasurementTypes == null || allMeasurementTypes?.isEmpty == true)) {
      title +=
          ' ${context.locale.common_measurement_types_genitive(selectedMeasurementType!.name).toLowerCase()}';
    }
    return title;
  }

  bool hasMeasurementTabs() {
    return (allMeasurementTypes != null && allMeasurementTypes!.length > 1);
  }

  @override
  Widget build(BuildContext context) {
    final session = getIt<Session>();

    final List<Device> supportedDevices = [];

    if (selectedMeasurementType != null) {
      supportedDevices.addAll(
        Constants.supportedDevices.where(
          (device) => device.supportedMeasurementTypes!.contains(
            selectedMeasurementType,
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
                  ...allMeasurementTypes!
                      .map(
                        (measurementType) => Row(
                          children: [
                            NavigationTabChip(
                              label: context.locale.common_measurement_types(
                                measurementType.name,
                              ),
                              isSelected:
                                  selectedMeasurementType == measurementType,
                              onTap: () {
                                if (selectedMeasurementType ==
                                    measurementType) {
                                  return;
                                }
                                selectedMeasurementType = measurementType;
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
          if (supportedDevices.isEmpty) ...[
            Gaps.gap24,
            Center(
              child: SvgPicture.asset(
                'assets/icons/icon_wave_pulse_big.svg',
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            Gaps.gap24,
            Padding(
              padding: Paddings.horizontal48,
              child: Center(
                child: Text(
                  context.locale.device_selector_unsupported_devices,
                  style: ScaleTextStyles.text
                      .apply(color: Theme.of(context).colorScheme.onSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ] else
            ...supportedDevices
                .map(
                  (supportedDevice) => InkWell(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      GoRouter.of(context).pushNamed(
                        OmronFlowRoute.name,
                        extra: [
                          widget.userId,
                          supportedDevice.localId,
                          selectedMeasurementType!.index
                        ],
                      );
                    },
                    child: Container(
                      padding: Paddings.top24,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadii.radius8,
                            child: Container(
                              color: Theme.of(context).colorScheme.onPrimary,
                              height: 128,
                              width: 128,
                              child: Image.asset(supportedDevice.imagePath!),
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
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                                Gaps.gap6,
                                Text(
                                  context.locale.measurement_dialog_device_desc(
                                    supportedDevice.deviceModel!.name,
                                  ),
                                  style: ScaleTextStyles.label.apply(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          if (session.userAccount!.userPermissions!.contains(
            UserPermission.canManuallyEnterMeasurement,
          )) ...[
            Gaps.gap24,
            HighlightedElevatedButton(
              label: context.locale.common_personal_record,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                GoRouter.of(context).pushNamed(
                  ManualMeasurementRoute.name,
                  extra: [widget.userId, selectedMeasurementType!],
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
