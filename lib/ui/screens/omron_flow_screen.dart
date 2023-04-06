import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc_event.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/popup_dialog_mixin.dart';
import 'package:scalesoft_app/ui/screens/synced_result.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/device_progress.dart';
import 'package:scalesoft_app/ui/widgets/process_item.dart';
import 'package:scalesoft_app/ui/widgets/warning_item.dart';

const Map<String, String> characteristicsMap = {
  "00002a49-0000-1000-8000-00805f9b34fb": 'Blood pressure feature char',
  "00002a35-0000-1000-8000-00805f9b34fb": 'Blood pressure measurement char'
};

class OmronFlowScreen extends StatefulWidget {
  const OmronFlowScreen({
    super.key,
    required this.userId,
    required this.device,
    required this.measurementType,
  });

  final String userId;
  final Device device;
  final MeasurementType measurementType;
  @override
  State<OmronFlowScreen> createState() => _OmronFlowScreenState();
}

class _OmronFlowScreenState extends State<OmronFlowScreen>
    with PopupDialogMixin {
  late final OmronConnectionBloc omronConnectionBloc;
  late final MeasurementType measurementType;
  late final Device device;

  bool get reqModelPairing =>
      device.reqPairing == true && device.macAddress == null;

  @override
  void initState() {
    omronConnectionBloc = getIt<OmronConnectionBloc>();

    device = widget.device;
    measurementType = widget.measurementType;

    super.initState();
  }

  Future<bool> _onWillPop() async {
    omronConnectionBloc.add(const OmronConnectionBlocEvent.stopSearch());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Material(
        child: Stack(
          children: [
            Positioned.fill(
              child: BlocBuilder<OmronConnectionBloc, OmronConnectionState>(
                bloc: omronConnectionBloc
                  ..add(
                    OmronConnectionBlocEvent.init(
                      widget.userId,
                      measurementType,
                      device,
                    ),
                  ),
                buildWhen: (previous, current) {
                  final showState = current.whenOrNull(
                        init: () => true,
                        disabledBt: () => true,
                        noBtPermissions: () => true,
                        searching: () => true,
                        connected: () => true,
                        syncing: () => true,
                        pairing: () => true,
                        synced: (measurementResult, deviceInfo) => true,
                        paired: (deviceInfo) => true,
                      ) ??
                      false;

                  return showState;
                },
                builder: ((context, state) {
                  final deviceStatusWidget = state.whenOrNull(
                    disabledBt: () {
                      return DeviceProgress(
                        header: WarningItem(
                          title: context
                              .locale.find_device_screen_disabled_bt_title,
                          description: context
                              .locale.find_device_screen_disabled_bt_desc,
                          buttonLabel: context.locale
                              .find_device_screen_disabled_bt_btn_settings,
                          icon: SvgPicture.asset(
                            'assets/icons/icon_bluetooth_slash_big.svg',
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onTap: () async {
                            AppSettings.openBluetoothSettings();
                          },
                        ),
                        device: device,
                        activeIndex: 0,
                        reqPairing: reqModelPairing,
                      );
                    },
                    noBtPermissions: () {
                      return DeviceProgress(
                        header: WarningItem(
                          title: context
                              .locale.find_device_screen_not_granted_bt_title,
                          description: context
                              .locale.find_device_screen_not_granted_bt_desc,
                          buttonLabel: context.locale
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
                          label: context
                              .locale.find_device_screen_searching_device,
                          processType: ProcessType.inProgress,
                        ),
                        device: device,
                        activeIndex: 0,
                        reqPairing: reqModelPairing,
                      );
                    },
                    searching: () {
                      return DeviceProgress(
                        header: ProcessItem(
                          label: context
                              .locale.find_device_screen_searching_device,
                          processType: ProcessType.inProgress,
                        ),
                        device: device,
                        activeIndex: 0,
                        reqPairing: reqModelPairing,
                      );
                    },
                    connected: () {
                      return DeviceProgress(
                        header: ProcessItem(
                          label: context
                              .locale.find_device_screen_device_connected,
                          processType: ProcessType.connected,
                        ),
                        device: device,
                        activeIndex: 0,
                        reqPairing: reqModelPairing,
                      );
                    },
                    pairing: () {
                      return DeviceProgress(
                        header: ProcessItem(
                          label:
                              context.locale.find_device_screen_pairing_device,
                          processType: ProcessType.inProgress,
                        ),
                        device: device,
                        activeIndex: 1,
                        reqPairing: reqModelPairing,
                      );
                    },
                    paired: (deviceInfo) {
                      return DeviceProgress(
                        header: ProcessItem(
                          label: context
                              .locale.find_device_screen_searching_device,
                          processType: ProcessType.inProgress,
                        ),
                        device: device,
                        activeIndex: 2,
                        reqPairing: reqModelPairing,
                      );
                    },
                    syncing: () {
                      return DeviceProgress(
                        header: ProcessItem(
                          label: context.locale.find_device_screen_sync_results,
                          processType: ProcessType.inProgress,
                        ),
                        device: device,
                        activeIndex: 2,
                        reqPairing: reqModelPairing,
                      );
                    },
                    synced: (hwMeasurementResult, deviceInfo) {
                      return SyncedResult(
                        userId: widget.userId,
                        deviceId: device.macAddress ?? '${device.localId}',
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
              child: BluredScaleAppBar(
                title: device.modelName ?? '',
                subTitle: '${context.locale.common_measurement} '
                    '${context.locale.common_measurement_types_genitive(measurementType.name).toLowerCase()}',
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
