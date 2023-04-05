import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_event.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/register_device_detail_route.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/device_item.dart';
import 'package:scalesoft_app/ui/widgets/process_item.dart';
import 'package:scalesoft_app/ui/widgets/warning_item.dart';

class RegisterDeviceSearchScreen extends StatefulWidget {
  const RegisterDeviceSearchScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<RegisterDeviceSearchScreen> createState() =>
      _RegisterDeviceSearchScreenState();
}

class _RegisterDeviceSearchScreenState
    extends State<RegisterDeviceSearchScreen> {
  final RegisterDeviceBloc registerDeviceBloc = getIt<RegisterDeviceBloc>();

  Future<bool> _onWillPop() async {
    registerDeviceBloc.add(const RegisterDeviceBlocEvent.stopSearch());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Material(
        child: Stack(
          children: [
            BlocBuilder<RegisterDeviceBloc, RegisterDeviceBlocState>(
              bloc: registerDeviceBloc
                ..add(const RegisterDeviceBlocEvent.init()),
              builder: (context, state) {
                final header = state.whenOrNull(
                  disabledBt: () => WarningItem(
                    title: context.locale.find_device_screen_disabled_bt_title,
                    description:
                        context.locale.find_device_screen_disabled_bt_desc,
                    buttonLabel: context
                        .locale.find_device_screen_disabled_bt_btn_settings,
                    icon: SvgPicture.asset(
                      'assets/icons/icon_bluetooth_slash_big.svg',
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onTap: () async {
                      AppSettings.openBluetoothSettings();
                    },
                  ),
                  noBtPermissions: () => WarningItem(
                    title:
                        context.locale.find_device_screen_not_granted_bt_title,
                    description:
                        context.locale.find_device_screen_not_granted_bt_desc,
                    buttonLabel: context
                        .locale.find_device_screen_not_granted_bt_btn_settings,
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
                    label: context.locale.find_device_screen_searching_device,
                    processType: ProcessType.inProgress,
                  ),
                  searching: (devices) => ProcessItem(
                    label: context.locale.find_device_screen_searching_device,
                    processType: ProcessType.inProgress,
                  ),
                );

                final btDevices =
                    state.whenOrNull(searching: (devices) => devices);

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: Paddings.horizontal16,
                        child: Column(
                          children: [
                            Gap(
                              MediaQuery.of(context).viewPadding.top +
                                  Constants.appBarHeight,
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
                                  context.locale
                                      .register_device_search_screen_desc,
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
                                GoRouter.of(context).replaceNamed(
                                  RegisterDeviceDetailRoute.name,
                                  params: {
                                    'userId': widget.userId,
                                    'localId': '${foundDev.localId!}',
                                    'macAddress': foundDev.macAddress!,
                                  },
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
                      )
                    }
                  ],
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BluredScaleAppBar(
                title: context.locale.register_device_search_screen_title,
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
