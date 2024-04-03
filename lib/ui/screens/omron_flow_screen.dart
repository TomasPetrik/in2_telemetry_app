import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc_event.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_state.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/screens/synced_result.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/device_progress.dart';
import 'package:scalesoft_app/ui/widgets/process_item.dart';
import 'package:scalesoft_app/ui/widgets/warning_item.dart';

class OmronFlowScreen extends StatefulWidget {
  const OmronFlowScreen({
    super.key,
    required this.userId,
    required this.device,
    required this.measurementType,
  });

  final String userId;
  final Device device;
  final MeasurementTypeContract measurementType;
  @override
  State<OmronFlowScreen> createState() => _OmronFlowScreenState();
}

class _OmronFlowScreenState extends State<OmronFlowScreen>
    with BottomSheetMixin, WidgetsBindingObserver {
  final OmronConnectionBloc omronConnectionBloc = getIt<OmronConnectionBloc>();
  late final MeasurementTypeContract measurementType;
  late final SourceDeviceContract device;

  bool get reqModelPairing =>
      device.reqPairing == true &&
      (device.deviceIdentifier == null || device.wasPaired != true);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint('didChangeAppLifecycleState ${state.toString()}');

    if (state == AppLifecycleState.resumed) {
      if (omronConnectionBloc.shouldRequestPermission == true) {
        omronConnectionBloc.add(const OmronConnectionBlocEvent.checkHwState());
      }
    }
  }

  @override
  void initState() {
    device = widget.device;
    measurementType = widget.measurementType;
    omronConnectionBloc.add(
      OmronConnectionBlocEvent.init(
        widget.userId,
        measurementType,
        device,
      ),
    );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onWillPop() {
    omronConnectionBloc.add(const OmronConnectionBlocEvent.stopSearch());
  }

  @override
  Widget build(BuildContext context) {
    // Workaround for https://github.com/flutter/flutter/issues/138737
    return WillPopScope(
      onWillPop: () async {
        _onWillPop();
        return true;
      },
      child: Material(
        child: Stack(
          children: [
            Positioned.fill(
              child: BlocConsumer<OmronConnectionBloc, OmronConnectionState>(
                bloc: omronConnectionBloc,
                buildWhen: (previous, current) {
                  final showState = current.whenOrNull(
                        init: () => true,
                        disabledBt: (_) => true,
                        notVerified: (_, measurementResult) => true,
                        noBtPermissions: (_) => true,
                        searching: (_) => true,
                        connected: (_) => true,
                        syncing: (_) => true,
                        pairing: (_) => true,
                        synced: (timestamp, measurementResult, deviceInfo) =>
                            true,
                        paired: (_, deviceInfo) => true,
                      ) ??
                      false;

                  return showState;
                },
                listener: (context, state) async {
                  state.whenOrNull(
                    notFound: (_) async {
                      await showDevNotFound(context).then((searchAgain) {
                        if (searchAgain == true) {
                          omronConnectionBloc.add(
                            const OmronConnectionBlocEvent.searchDevice(),
                          );
                        } else if (searchAgain == false) {
                          Navigator.of(context).pop();
                        }
                      });
                    },
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
                builder: ((context, state) {
                  final deviceStatusWidget = state.whenOrNull(
                    disabledBt: (_) {
                      return DeviceProgress(
                        header: WarningItem(
                          title:
                              localization.find_device_screen_disabled_bt_title,
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
                        device: device,
                        activeIndex: 0,
                        reqPairing: reqModelPairing,
                      );
                    },
                    noBtPermissions: (_) {
                      return DeviceProgress(
                        header: WarningItem(
                          title: localization
                              .find_device_screen_not_granted_bt_title,
                          description: localization
                              .find_device_screen_not_granted_bt_desc,
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
                        device: device,
                        activeIndex: 0,
                        reqPairing: reqModelPairing,
                      );
                    },
                    init: () {
                      return DeviceProgress(
                        header: ProcessItem(
                          label: reqModelPairing
                              ? localization.find_device_screen_searching_device
                              : localization
                                  .find_device_screen_waiting_on_measurement,
                          processType: ProcessType.inProgress,
                        ),
                        device: device,
                        activeIndex: 0,
                        reqPairing: reqModelPairing,
                      );
                    },
                    searching: (_) {
                      return DeviceProgress(
                        header: ProcessItem(
                          label: reqModelPairing
                              ? localization
                                  .find_device_screen_searching_tonometer
                              : localization
                                  .find_device_screen_waiting_on_measurement,
                          processType: ProcessType.inProgress,
                        ),
                        device: device,
                        activeIndex: 0,
                        reqPairing: reqModelPairing,
                      );
                    },
                    connected: (_) {
                      return DeviceProgress(
                        header: ProcessItem(
                          label:
                              localization.find_device_screen_device_connected,
                          processType: ProcessType.connected,
                        ),
                        device: device,
                        activeIndex: 0,
                        reqPairing: reqModelPairing,
                      );
                    },
                    notVerified: (_, hwMeasurementResult) {
                      return SyncedResult(
                        key: ValueKey(hwMeasurementResult.hashCode),
                        userId: widget.userId,
                        deviceId: hwMeasurementResult.devId,
                        hwMeasurementResult: hwMeasurementResult,
                        measurementType: measurementType,
                      );
                    },
                    pairing: (_) {
                      return DeviceProgress(
                        header: ProcessItem(
                          label: localization.find_device_screen_pairing_device,
                          processType: ProcessType.inProgress,
                        ),
                        device: device,
                        activeIndex: 1,
                        reqPairing: reqModelPairing,
                      );
                    },
                    paired: (_, deviceInfo) {
                      return DeviceProgress(
                        header: ProcessItem(
                          label: localization
                              .find_device_screen_waiting_on_measurement,
                          processType: ProcessType.inProgress,
                        ),
                        device: device,
                        activeIndex: 2,
                        reqPairing: reqModelPairing,
                      );
                    },
                    syncing: (
                      _,
                    ) {
                      return DeviceProgress(
                        header: ProcessItem(
                          label: localization.find_device_screen_sync_results,
                          processType: ProcessType.inProgress,
                        ),
                        device: device,
                        activeIndex: 2,
                        reqPairing: reqModelPairing,
                      );
                    },
                    synced: (
                      timestamp,
                      hwMeasurementResult,
                      deviceInfo,
                    ) {
                      return SyncedResult(
                        key: ValueKey(timestamp),
                        userId: widget.userId,
                        deviceId: hwMeasurementResult.devId,
                        hwMeasurementResult: hwMeasurementResult,
                        measurementType: measurementType,
                        deviceInfo: deviceInfo,
                      );
                    },
                  );

                  return Padding(
                    padding: Paddings.horizontal16,
                    child: deviceStatusWidget ?? const SizedBox.shrink(),
                  );
                }),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BlurredScaleAppBar(
                title: device.visibleName ?? '',
                subTitle: '${localization.common_measurement} '
                    '${localization.common_measurement_types_genitive(measurementType.name).toLowerCase()}',
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
