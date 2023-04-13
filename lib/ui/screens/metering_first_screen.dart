import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/cubit/device_management/device_management_cubit.dart';
import 'package:scalesoft_app/cubit/device_management/device_management_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/storage/session.dart';
import 'package:scalesoft_app/ui/routers/routes/add_device_route.dart';
import 'package:scalesoft_app/ui/routers/routes/manual_measurement_route.dart';
import 'package:scalesoft_app/ui/routers/routes/omron_flow_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/device_item.dart';
import 'package:scalesoft_app/ui/widgets/navigation_tab_chip.dart';
import 'package:scalesoft_app/ui/widgets/settings_item.dart';

class MeteringFirstScreen extends StatefulWidget {
  const MeteringFirstScreen({
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
  State<MeteringFirstScreen> createState() => _MeteringFirstScreenState();
}

class _MeteringFirstScreenState extends State<MeteringFirstScreen>
    with BottomSheetMixin {
  final session = getIt<Session>();
  final DeviceManagementCubit devManagementCubit =
      getIt<DeviceManagementCubit>();
  late MeasurementType defaultMeasurementType;

  @override
  void initState() {
    defaultMeasurementType =
        widget.selectedMeasurementType ?? widget.allMeasurementTypes!.first;

    super.initState();
  }

  String getTitle() {
    String title = translactions.common_measurement;
    if (widget.selectedMeasurementType != null) {
      title +=
          ' ${translactions.common_measurement_types_genitive(defaultMeasurementType.name).toLowerCase()}';
    }
    return title;
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
                          widget.allMeasurementTypes!.first,
                      widget.allMeasurementTypes,
                    ),
                  builder: (context, state) {
                    final selectedMeasurementType =
                        state.selectedMeasurementType;
                    final supportDeviceMeasurement =
                        state.supportDeviceMeasurement;

                    final suitableDevices = state.devices ?? [];

                    if (selectedMeasurementType == null ||
                        supportDeviceMeasurement == null) {
                      return const SizedBox.shrink();
                    }

                    return Column(
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
                                            label: translactions
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
                                translactions
                                    .device_selector_unsupported_devices,
                                style: ScaleTextStyles.text.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ] else if (suitableDevices.isNotEmpty == true)
                          ...suitableDevices
                              .map(
                                (supportedDevice) => InkWell(
                                  onTap: () {
                                    GoRouter.of(context).pushNamed(
                                      OmronFlowRoute.name,
                                      params: {
                                        'userId': widget.userId,
                                        'measurementType':
                                            selectedMeasurementType.name,
                                        'deviceId': supportedDevice.macAddress!
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: Paddings.top24,
                                    child: DeviceItem(
                                      device: supportedDevice,
                                      onRemove: () async {
                                        final confirmed =
                                            await showDeviceRemovalConfirmation(
                                          context: context,
                                        );

                                        if (confirmed == true) {
                                          devManagementCubit.removeDevice(
                                            supportedDevice,
                                            selectedMeasurementType,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              )
                              .toList()
                        else ...[
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
                                translactions
                                    .metering_screen_no_added_device_yet,
                                style: ScaleTextStyles.text.apply(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        if (supportDeviceMeasurement) ...[
                          Gaps.gap24,
                          SettingsItem(
                            label: translactions.metering_screen_add_device,
                            iconWidget: SvgPicture.asset(
                              'assets/icons/icon_plus.svg',
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            hasNavigationIcon: false,
                            onTap: () {
                              GoRouter.of(context).pushNamed(
                                AddDeviceRoute.name,
                                params: {
                                  'userId': widget.userId,
                                  'measurementType':
                                      selectedMeasurementType.name
                                },
                              );
                            },
                          ),
                        ],
                        if (session.userAccount!.userPermissions!.contains(
                          UserPermission.canManuallyEnterMeasurement,
                        )) ...[
                          Gaps.gap24,
                          SettingsItem(
                            label: translactions.common_personal_record,
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
            child: BluredScaleAppBar(
              title: getTitle(),
              showClose: true,
            ),
          ),
        ],
      ),
    );
  }
}
