import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/cubit/device_management/device_management_cubit.dart';
import 'package:scalesoft_app/cubit/device_management/device_management_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/device_search_route.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_measurement_route.dart';
import 'package:scalesoft_app/ui/routers/routes/omron_flow_route.dart';
import 'package:scalesoft_app/ui/screens/device_search_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/device_item.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/utils/helpers/care_plan_helper.dart';

class MeteringFirstScreen extends StatefulWidget {
  const MeteringFirstScreen({
    super.key,
    required this.userId,
    this.selectedMeasurementType,
    required this.showAllMeasurementTypes,
  });

  final String userId;
  final MeasurementTypeContract? selectedMeasurementType;
  final bool showAllMeasurementTypes;

  @override
  State<MeteringFirstScreen> createState() => _MeteringFirstScreenState();
}

class _MeteringFirstScreenState extends State<MeteringFirstScreen>
    with BottomSheetMixin {
  late UserAccount userAccount;
  final DeviceManagementCubit devManagementCubit =
      getIt<DeviceManagementCubit>();
  late MeasurementTypeContract defaultMeasurementType;
  late Set<MeasurementTypeContract> displayedMeasurementTypes;

  @override
  void initState() {
    userAccount = getIt<AccountDbProvider>().get(widget.userId)!;

    final supportedUserMeasurementTypes =
        CarePlanHelper.getMeasurementTypes(userAccount.carePlans!);

    if (widget.showAllMeasurementTypes ||
        supportedUserMeasurementTypes.isEmpty) {
      displayedMeasurementTypes =
          userAccount.hospital?.enabledMeasurementTypes.toSet() ??
              ConfigurationConstants.supportedMeasurementTypes;
    } else {
      displayedMeasurementTypes = supportedUserMeasurementTypes;
    }

    defaultMeasurementType =
        widget.selectedMeasurementType ?? displayedMeasurementTypes.first;

    super.initState();
  }

  String getTitle() {
    String title = localization.common_measurement;
    if (widget.selectedMeasurementType != null) {
      title +=
          ' ${localization.common_measurement_types_genitive(defaultMeasurementType.name).toLowerCase()}';
    }
    return title;
  }

  void goToMetering(Device device, MeasurementTypeContract measurementType) {
    GoRouter.of(context).pushNamed(
      OmronFlowRoute.name,
      queryParams: {
        'userId': widget.userId,
        'measurementType': measurementType.name,
        'deviceId': device.deviceIdentifier!,
        'modelName': '${device.modelName}',
        'deviceManufacturer': '${device.deviceManufacturer}',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  MediaQuery.of(context).viewPadding.top +
                      Dimensions.appBarHeight,
                ),
                BlocBuilder<DeviceManagementCubit, DeviceManagementState>(
                  bloc: devManagementCubit
                    ..init(
                      widget.selectedMeasurementType ??
                          displayedMeasurementTypes.first,
                      displayedMeasurementTypes,
                      widget.userId,
                    ),
                  builder: (context, state) {
                    final selectedMeasurementType =
                        state.selectedMeasurementType;
                    final supportDeviceMeasurement =
                        state.supportDeviceMeasurement;

                    final assignedDevices = state.assignedDevices
                            ?.where(
                              (x) =>
                                  x.measurementFlow
                                      ?.hasFlag(MeasurementFlow.foreground) ??
                                  true,
                            )
                            .toList() ??
                        [];
                    final personalDevices = state.personalDevices ?? [];

                    if (selectedMeasurementType == null ||
                        supportDeviceMeasurement == null) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.hasMeasurementTabs == true) ...[
                          Gaps.gap16,
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ...state.allMeasurementTypes!
                                    .map(
                                      (measurementType) => Row(
                                        children: [
                                          NavigationTabChip(
                                            label: localization
                                                .common_measurement_types(
                                              measurementType.name,
                                            ),
                                            isSelected:
                                                selectedMeasurementType ==
                                                    measurementType,
                                            onTap: () {
                                              if (selectedMeasurementType ==
                                                  measurementType) {
                                                return;
                                              }

                                              devManagementCubit
                                                  .selectMeasurementType(
                                                measurementType,
                                              );
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
                                localization
                                    .device_selector_unsupported_devices,
                                style: ScaleTextStyles.text.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ] else if (assignedDevices.isNotEmpty ||
                            personalDevices.isNotEmpty) ...[
                          if (assignedDevices.isNotEmpty) ...[
                            Gaps.gap24,
                            Text(
                              localization.metering_screen_lended_devices,
                              style: ScaleTextStyles.label.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            ...assignedDevices
                                .map(
                                  (assignedDevice) => InkWell(
                                    onTap: () {
                                      goToMetering(
                                        assignedDevice,
                                        selectedMeasurementType,
                                      );
                                    },
                                    child: Container(
                                      padding: Paddings.top24,
                                      child: DeviceItem(
                                        device: assignedDevice,
                                        onRemove:
                                            assignedDevice.wasPaired == true
                                                ? () async {
                                                    final confirmed =
                                                        await showDeviceRemovalConfirmation(
                                                      context: context,
                                                    );

                                                    if (confirmed == true) {
                                                      devManagementCubit
                                                          .removeDevice(
                                                        assignedDevice,
                                                        selectedMeasurementType,
                                                      );
                                                    }
                                                  }
                                                : null,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                          if (personalDevices.isNotEmpty) ...[
                            Gaps.gap24,
                            Text(
                              localization.metering_screen_personal_devices,
                              style: ScaleTextStyles.label.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            ...personalDevices
                                .map(
                                  (personalDevice) => InkWell(
                                    onTap: () {
                                      goToMetering(
                                        personalDevice,
                                        selectedMeasurementType,
                                      );
                                    },
                                    child: Container(
                                      padding: Paddings.top24,
                                      child: DeviceItem(
                                        device: personalDevice,
                                        onRemove:
                                            personalDevice.isLendedDevice !=
                                                    true
                                                ? () async {
                                                    final confirmed =
                                                        await showDeviceRemovalConfirmation(
                                                      context: context,
                                                    );

                                                    if (confirmed == true) {
                                                      devManagementCubit
                                                          .removeDevice(
                                                        personalDevice,
                                                        selectedMeasurementType,
                                                      );
                                                    }
                                                  }
                                                : null,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ] else if (userAccount.canMeasureWithUnknowDevice) ...[
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
                                localization
                                    .metering_screen_no_added_device_yet,
                                style: ScaleTextStyles.text.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
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
                                localization
                                    .metering_screen_no_eligible_to_measure_with_uknow_device,
                                style: ScaleTextStyles.text.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        if (supportDeviceMeasurement &&
                            userAccount.canMeasureWithUnknowDevice) ...[
                          Gaps.gap24,
                          SettingsItem(
                            label: localization.metering_screen_add_device,
                            iconWidget: SvgPicture.asset(
                              'assets/icons/icon_plus.svg',
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            hasNavigationIcon: false,
                            onTap: () async {
                              GoRouter.of(context).pushNamed<Device?>(
                                DeviceSearchRoute.name,
                                params: {
                                  'userId': userAccount.user.muid,
                                  'devicePurpose': DevicePurpose.addDevice.name,
                                },
                              ).then((final Device? device) {
                                if (device != null) {
                                  GoRouter.of(context).replaceNamed(
                                    OmronFlowRoute.name,
                                    queryParams: {
                                      'userId': widget.userId,
                                      'measurementType':
                                          selectedMeasurementType.name,
                                      'modelName': '${device.modelName}',
                                      'deviceManufacturer':
                                          '${device.deviceManufacturer}',
                                    },
                                  );
                                }
                              });

                              /*
                              GoRouter.of(context).pushNamed(
                                AddDeviceRoute.name,
                                params: {
                                  'userId': widget.userId,
                                  'measurementType':
                                      selectedMeasurementType.name,
                                },
                              );
                              */
                            },
                          ),
                        ],
                        if (userAccount.userPermissions!.contains(
                          UserPermission.canManuallyEnterMeasurement,
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
                                params: {
                                  'userId': widget.userId,
                                  'measurementType':
                                      selectedMeasurementType.name,
                                  'showAllMeasurementTypes':
                                      widget.showAllMeasurementTypes.toString(),
                                },
                              );
                            },
                          ),
                        ],
                        Gaps.gap48,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredScaleAppBar(
              title: getTitle(),
              showClose: true,
            ),
          ),
        ],
      ),
    );
  }
}
