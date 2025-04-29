import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/constants/permissions.dart';
import 'package:scalesoft_app/cubit/care_plan/care_plan_cubit.dart';
import 'package:scalesoft_app/cubit/care_plan/care_plan_cubit_state.dart';
import 'package:scalesoft_app/cubit/device_management/device_management_cubit.dart';
import 'package:scalesoft_app/cubit/device_management/device_management_state.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_flow.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/user_cubit.dart';
import 'package:scalesoft_app/ui/routers/routes/device_connection_flow_route.dart';
import 'package:scalesoft_app/ui/routers/routes/device_search_route.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_measurement_route.dart';
import 'package:scalesoft_app/ui/screens/device_search_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/device_item.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class MeteringFirstScreen extends StatelessWidget with BottomSheetMixin {
  MeteringFirstScreen({
    super.key,
    required this.userId,
    this.selectedMeasurementType,
    required this.showAllMeasurementTypes,
  });

  final int userId;
  final MeasurementType? selectedMeasurementType;
  final bool showAllMeasurementTypes;

  final DeviceManagementCubit devManagementCubit = getIt<DeviceManagementCubit>();
  final UserCubit userCubit = getIt<UserCubit>();
  final CarePlanCubit carePlanCubit = CarePlanCubit();

  String getTitle(MeasurementType defaultMeasurementType) {
    String title = localization.common_measurement;
    if (selectedMeasurementType != null) {
      title += ' ${localization.common_measurement_types_genitive(defaultMeasurementType.name).toLowerCase()}';
    }
    return title;
  }

  void goToMetering(DeviceCreateModel device, MeasurementType measurementType, BuildContext context) {
    GoRouter.of(context).pushNamed(
      DeviceConnectionFlowRoute.name,
      queryParameters: {
        'userId': userId.toString(),
        'measurementType': measurementType.name,
      },
      extra: device,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserCubitState>(
      bloc: userCubit,
      builder: (context, userState) {
        return BlocBuilder<CarePlanCubit, CarePlanCubitState>(
          bloc: carePlanCubit..init(userId),
          builder: (context, carePlanState) {
            final userAccount = userState.allUsers.firstWhere((x) => x.id == userId);
            final userCarePlans = carePlanState.carePlans;

            final measurementTypesInPlans = CarePlanHelper.getMeasurementTypes(userCarePlans);
            final displayedMeasurementTypes = (showAllMeasurementTypes || measurementTypesInPlans.isEmpty)
                ? userAccount.hospital.enabledMeasurementTypes.toSet()
                : measurementTypesInPlans;

            final defaultMeasurementType = selectedMeasurementType ?? displayedMeasurementTypes.first;

            return BlocBuilder<DeviceManagementCubit, DeviceManagementState>(
              bloc: devManagementCubit
                ..init(
                  selectedMeasurementType ?? displayedMeasurementTypes.first,
                  displayedMeasurementTypes,
                  userId,
                ),
              builder: (context, deviceManagementState) {
                final selectedMeasurementType = deviceManagementState.selectedMeasurementType;
                final supportDeviceMeasurement = deviceManagementState.supportDeviceMeasurement;

                final assignedDevices = deviceManagementState.assignedDevices
                        ?.where(
                          (x) => x.prototype.measurementFlow.hasFlag(MeasurementFlow.foreground),
                        )
                        .toList() ??
                    [];
                final personalDevices = deviceManagementState.personalDevices ?? [];

                return Material(
                  child: Stack(
                    children: [
                      Container(
                        padding: Paddings.horizontal16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Gap(
                              MediaQuery.of(context).viewPadding.top + Dimensions.appBarHeight,
                            ),
                            if (selectedMeasurementType == null || supportDeviceMeasurement == null)
                              const SizedBox.shrink()
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (deviceManagementState.hasMeasurementTabs == true) ...[
                                    Gaps.gap16,
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          ...deviceManagementState.allMeasurementTypes!.map(
                                            (measurementType) => Row(
                                              children: [
                                                NavigationTabChip(
                                                  label: localization.common_measurement_types(
                                                    measurementType.name,
                                                  ),
                                                  isSelected: selectedMeasurementType == measurementType,
                                                  onTap: () {
                                                    if (selectedMeasurementType == measurementType) {
                                                      return;
                                                    }

                                                    devManagementCubit.selectMeasurementType(
                                                      measurementType,
                                                    );
                                                  },
                                                ),
                                                Gaps.gap8,
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (supportDeviceMeasurement == false) ...[
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
                                          localization.device_selector_unsupported_devices,
                                          style: ScaleTextStyles.text.apply(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ] else if (assignedDevices.isNotEmpty || personalDevices.isNotEmpty) ...[
                                    if (assignedDevices.isNotEmpty) ...[
                                      Gaps.gap24,
                                      Text(
                                        localization.metering_screen_lended_devices,
                                        style: ScaleTextStyles.label.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                      ...assignedDevices.map(
                                        (assignedDevice) => InkWell(
                                          onTap: () {
                                            goToMetering(
                                              assignedDevice,
                                              selectedMeasurementType,
                                              context,
                                            );
                                          },
                                          child: Container(
                                            padding: Paddings.top24,
                                            child: DeviceItem(
                                              device: assignedDevice,
                                              onRemove: assignedDevice.isPaired
                                                  ? () async {
                                                      final confirmed = await showDeviceRemovalConfirmation(
                                                        context: context,
                                                      );

                                                      if (confirmed == true) {
                                                        devManagementCubit.removeDevice(
                                                          assignedDevice,
                                                          selectedMeasurementType,
                                                        );
                                                      }
                                                    }
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (personalDevices.isNotEmpty) ...[
                                      Gaps.gap24,
                                      Text(
                                        localization.metering_screen_personal_devices,
                                        style: ScaleTextStyles.label.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                      ...personalDevices.map(
                                        (personalDevice) => InkWell(
                                          onTap: () {
                                            goToMetering(
                                              personalDevice,
                                              selectedMeasurementType,
                                              context,
                                            );
                                          },
                                          child: Container(
                                            padding: Paddings.top24,
                                            child: DeviceItem(
                                              device: personalDevice,
                                              onRemove: personalDevice.isPersonal
                                                  ? () async {
                                                      final confirmed = await showDeviceRemovalConfirmation(
                                                        context: context,
                                                      );

                                                      if (confirmed == true) {
                                                        devManagementCubit.removeDevice(
                                                          personalDevice,
                                                          selectedMeasurementType,
                                                        );
                                                      }
                                                    }
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ] else if (userAccount.permissions
                                      .contains(Permissions.measureWithUnknownDevice)) ...[
                                    Gaps.gap24,
                                    Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/icon_bluetooth_signal_big.svg',
                                        color: Theme.of(context).colorScheme.tertiary,
                                      ),
                                    ),
                                    Gaps.gap24,
                                    Padding(
                                      padding: Paddings.horizontal48,
                                      child: Center(
                                        child: Text(
                                          localization.metering_screen_no_added_device_yet,
                                          style: ScaleTextStyles.text.apply(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Gaps.gap24,
                                    Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/icon_triangle_exclamation_big.svg',
                                        color: Theme.of(context).colorScheme.tertiary,
                                      ),
                                    ),
                                    Gaps.gap24,
                                    Padding(
                                      padding: Paddings.horizontal48,
                                      child: Center(
                                        child: Text(
                                          localization.metering_screen_no_eligible_to_measure_with_uknow_device,
                                          style: ScaleTextStyles.text.apply(
                                            color: Theme.of(context).colorScheme.onSecondary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (supportDeviceMeasurement &&
                                      userAccount.permissions.contains(Permissions.measureWithUnknownDevice)) ...[
                                    Gaps.gap24,
                                    SettingsItem(
                                      label: localization.metering_screen_add_device,
                                      iconWidget: SvgPicture.asset(
                                        'assets/icons/icon_plus.svg',
                                        color: Theme.of(context).colorScheme.onSecondary,
                                      ),
                                      hasNavigationIcon: false,
                                      onTap: () async {
                                        debugPrint(selectedMeasurementType.name);
                                        GoRouter.of(context).pushNamed<DeviceCreateModel?>(
                                          DeviceSearchRoute.name,
                                          pathParameters: {
                                            'userId': userAccount.id.toString(),
                                            'devicePurpose': DevicePurpose.addDevice.name,
                                            'measurementType' : selectedMeasurementType.name,
                                          },
                                        ).then((final DeviceCreateModel? device) {
                                          if (device != null) {
                                            GoRouter.of(context).replaceNamed(
                                              DeviceConnectionFlowRoute.name,
                                              queryParameters: {
                                                'userId': userId.toString(),
                                                'measurementType': selectedMeasurementType.name,
                                              },
                                              extra: device,
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                  if (userAccount.permissions.contains(
                                    Permissions.manuallyEnterMeasurement,
                                  )) ...[
                                    Gaps.gap24,
                                    SettingsItem(
                                      label: localization.common_personal_record,
                                      iconWidget: SvgPicture.asset(
                                        'assets/icons/icon_square_pen_medium.svg',
                                        color: Theme.of(context).colorScheme.onSecondary,
                                      ),
                                      hasNavigationIcon: false,
                                      onTap: () {
                                        GoRouter.of(context).pushNamed(
                                          ManualMeasurementRoute.name,
                                          pathParameters: {
                                            'userId': userId.toString(),
                                            'measurementType': selectedMeasurementType.name,
                                          },
                                          extra: displayedMeasurementTypes,
                                        );
                                      },
                                    ),
                                  ],
                                  Gaps.gap48,
                                ],
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: BlurredScaleAppBar(
                          title: getTitle(defaultMeasurementType),
                          showClose: true,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
