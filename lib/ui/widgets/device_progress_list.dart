import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/icon_label_row.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class DeviceProgressList extends StatelessWidget {
  const DeviceProgressList({
    super.key,
    required this.device,
    required this.reqPairing,
    required this.activeIndex,
  });

  final Device device;
  final bool reqPairing;
  final int activeIndex;

  List<ConnectionState> getConnectionStates(BuildContext context) {
    if (reqPairing) {
      return [
        ConnectionState(
          'assets/icons/icon_power_off.svg',
          translactions.find_device_screen_step1_p(device.modelName!),
          1,
        ),
        ConnectionState(
          'assets/icons/icon_bluetooth_on.svg',
          translactions.find_device_screen_step2_p,
          1,
        ),
        ConnectionState(
          'assets/icons/icon_arrow_spin.svg',
          translactions.find_device_screen_step3_p,
          2,
        ),
        ConnectionState(
          'assets/icons/icon_wave_pulse.svg',
          translactions.find_device_screen_step4_p(
            translactions
                .common_action_button_label(device.actionButtonType!.name),
          ),
          3,
        ),
        ConnectionState(
          'assets/icons/icon_arrow_spin.svg',
          translactions.find_device_screen_step5_p,
          3,
        )
      ];
    } else {
      return [
        if (device.askToActivateBt == true) ...{
          ConnectionState(
            'assets/icons/icon_circle_information.svg',
            translactions.find_device_screen_step1(device.modelName!),
            1,
          )
        },
        ConnectionState(
          'assets/icons/icon_power_off.svg',
          translactions.find_device_screen_step2(
            translactions
                .common_action_button_label(device.actionButtonType!.name),
          ),
          1,
        ),
        if (device.askToConfirmMeasurement == true) ...{
          ConnectionState(
            'assets/icons/icon_wave_pulse.svg',
            translactions.find_device_screen_step3,
            1,
          )
        },
        ConnectionState(
          'assets/icons/icon_arrow_spin.svg',
          translactions.find_device_screen_step4,
          1,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final connectionState = getConnectionStates(context)[index];
          return Column(
            children: [
              const Gap(Dimensions.padding34),
              ConnectionLevel(
                label: connectionState.label,
                iconPath: connectionState.iconPath,
                isActive: activeIndex >= connectionState.index,
              ),
            ],
          );
        },
        childCount: getConnectionStates(context).length,
      ),
    );
  }
}

class ConnectionState {
  String iconPath;
  String label;
  int index;

  ConnectionState(this.iconPath, this.label, this.index);
}
