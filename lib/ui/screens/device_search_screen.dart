import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_event.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/device_item.dart';
import 'package:scalesoft_app/ui/widgets/process_item.dart';
import 'package:scalesoft_app/ui/widgets/warning_item.dart';

enum DevicePurpose {
  addDevice, //require pairing process
  registerDevice,
}

class DeviceSearchScreen extends StatefulWidget {
  const DeviceSearchScreen({
    super.key,
    required this.userId,
    required this.devicePurpose,
  });

  final String userId;
  final DevicePurpose devicePurpose;

  @override
  State<DeviceSearchScreen> createState() => _DeviceSearchScreenState();
}

class _DeviceSearchScreenState extends State<DeviceSearchScreen>
    with BottomSheetMixin, WidgetsBindingObserver {
  final RegisterDeviceBloc registerDeviceBloc = getIt<RegisterDeviceBloc>();

  void _onWillPop() {
    registerDeviceBloc.add(const RegisterDeviceBlocEvent.stopSearch());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (registerDeviceBloc.shouldRequestPermission == true) {
        registerDeviceBloc.add(const RegisterDeviceBlocEvent.checkHwState());
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Workaround for https://github.com/flutter/flutter/issues/138737
      canPop: false,
      onPopInvoked: (_) {
        _onWillPop();
        GoRouter.of(context).pop();
      },
      child: Material(
        child: Stack(
          children: [
            BlocConsumer<RegisterDeviceBloc, RegisterDeviceBlocState>(
              bloc: registerDeviceBloc
                ..add(
                  RegisterDeviceBlocEvent.init(
                    userId: widget.userId,
                    onlyPairingMode:
                        widget.devicePurpose == DevicePurpose.addDevice,
                  ),
                ),
              listener: (BuildContext context, RegisterDeviceBlocState state) {
                state.whenOrNull(
                  popDevice: (devToPop) => Navigator.of(context).pop(devToPop),
                  disabledLocalizationService: (_) {
                    showLocalizationSettings(context: context)
                        .then((openLocationSettings) async {
                      if (openLocationSettings == true) {
                        await AppSettings.openAppSettings(
                          type: AppSettingsType.location,
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    });
                  },
                );
              },
              builder: (context, state) {
                final header = state.whenOrNull(
                  disabledBt: (_) => WarningItem(
                    title: localization.find_device_screen_disabled_bt_title,
                    description:
                        localization.find_device_screen_disabled_bt_desc,
                    buttonLabel: localization
                        .find_device_screen_disabled_bt_btn_settings,
                    icon: SvgPicture.asset(
                      'assets/icons/icon_bluetooth_slash_big.svg',
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onTap: () async {
                      AppSettings.openAppSettings(
                        type: AppSettingsType.bluetooth,
                      );
                    },
                  ),
                  noBtPermissions: (_) => WarningItem(
                    title: localization.find_device_screen_not_granted_bt_title,
                    description:
                        localization.find_device_screen_not_granted_bt_desc,
                    buttonLabel: localization
                        .find_device_screen_not_granted_bt_btn_settings,
                    icon: SvgPicture.asset(
                      'assets/icons/icon_bluetooth_slash_big.svg',
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onTap: () async {
                      await AppSettings.openAppSettings(
                        asAnotherTask: true,
                      );
                    },
                  ),
                  init: () => ProcessItem(
                    label: localization.find_device_screen_searching_device,
                    processType: ProcessType.inProgress,
                  ),
                  searching: (_, devices) => ProcessItem(
                    label: localization.find_device_screen_searching_device,
                    processType: ProcessType.inProgress,
                  ),
                );

                final btDevices =
                    state.whenOrNull(searching: (_, devices) => devices);

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: Paddings.horizontal16,
                        child: Column(
                          children: [
                            Gap(
                              MediaQuery.of(context).viewPadding.top +
                                  Dimensions.appBarHeight,
                            ),
                            Gaps.gap16,
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
                                      .device_search_screen_purpose_desc(
                                    widget.devicePurpose.name,
                                  ),
                                  style: ScaleTextStyles.text.apply(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverGap(Dimensions.padding24),
                    if (header != null)
                      SliverPadding(
                        padding: Paddings.horizontal16,
                        sliver: header,
                      ),
                    if (btDevices?.isNotEmpty == true) ...{
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final foundDev = btDevices[index];
                            return InkWell(
                              onTap: () {
                                registerDeviceBloc.add(
                                  RegisterDeviceBlocEvent.selectDevice(
                                    foundDev,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: Dimensions.padding24,
                                  left: Dimensions.padding16,
                                  right: Dimensions.padding16,
                                ),
                                child: DeviceItem(
                                  device: foundDev,
                                ),
                              ),
                            );
                          },
                          childCount: btDevices!.length,
                        ),
                      ),
                    },
                  ],
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BlurredScaleAppBar(
                title: localization.device_search_screen_purpose_title(
                  widget.devicePurpose.name,
                ),
                showClose: true,
                onCloseTap: _onWillPop,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
