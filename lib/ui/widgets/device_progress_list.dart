import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/cubit/device_instructions/device_instructions_cubit.dart';
import 'package:scalesoft_app/cubit/device_instructions/device_instructions_state.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/device_instruction_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/icon_label_row.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class DeviceProgressList extends StatelessWidget {
  DeviceProgressList({
    super.key,
    required this.device,
    required this.reqPairing,
    required this.activeIndex,
  });
  final DeviceInstructionsCubit _deviceInstructionsCubit = getIt<DeviceInstructionsCubit>();
  final DeviceCreateModel device;
  final bool reqPairing;
  final int activeIndex;

  List<DeviceInstruction> getDeviceInstructions(BuildContext context, int currentIndex) {
      List<DeviceInstruction> deviceInstructions = List.empty(growable: true);
      deviceInstructions.add(DeviceInstruction(id: 1, remoteId: 6, prototypeId: 1, index: 1, languageCode: "cs", instructionType: "Pairing", instructionText: "test index 1", lastModifiedTime: DateTime.now()));
      deviceInstructions.add(DeviceInstruction(id: 3, remoteId: 8, prototypeId: 1, index: 1, languageCode: "cs", instructionType: "Pairing", instructionText: "test index 1 1", lastModifiedTime: DateTime.now()));
      deviceInstructions.add(DeviceInstruction(id: 2, remoteId: 7, prototypeId: 1, index: 2, languageCode: "cs", instructionType: "Pairing", instructionText: "test index 2", lastModifiedTime: DateTime.now()));
      deviceInstructions.add(DeviceInstruction(id: 4, remoteId: 10, prototypeId: 1, index: 3, languageCode: "cs", instructionType: "Pairing", instructionText: "test index 3", lastModifiedTime: DateTime.now()));
      deviceInstructions.add(DeviceInstruction(id: 5, remoteId: 9, prototypeId: 1, index: 3, languageCode: "cs", instructionType: "Pairing", instructionText: "test index 3 3", lastModifiedTime: DateTime.now()));
      return deviceInstructions.where((x) => x.index == currentIndex).toList();
  }

  List<ConnectionState> getConnectionStates(BuildContext context) {
    if (reqPairing) {
      return [
        ConnectionState(
          'assets/icons/icon_power_off.svg',
          localization.find_device_screen_step1_p(device.prototype.visibleName),
          1,
        ),
        ConnectionState(
          'assets/icons/icon_bluetooth_on.svg',
          localization.find_device_screen_step2_p,
          1,
        ),
        ConnectionState(
          'assets/icons/icon_arrow_spin.svg',
          localization.find_device_screen_step3_p,
          2,
        ),
        ConnectionState(
          'assets/icons/icon_wave_pulse.svg',
          localization.find_device_screen_step4_p(
            localization.common_action_button_label(device.prototype.actionButtonType!.name),
          ),
          3,
        ),
        ConnectionState(
          'assets/icons/icon_arrow_spin.svg',
          localization.find_device_screen_step5_p,
          3,
        ),
      ];
    } else {
      return [
        if (device.prototype.askToActivateBt) ...{
          ConnectionState(
            'assets/icons/icon_circle_information.svg',
            localization.find_device_screen_step1(device.prototype.visibleName),
            1,
          ),
        },
        ConnectionState(
          'assets/icons/icon_power_off.svg',
          localization.find_device_screen_step2(
            localization.common_action_button_label(device.prototype.actionButtonType!.name),
          ),
          1,
        ),
        if (device.prototype.askToConfirmMeasurement) ...{
          ConnectionState(
            'assets/icons/icon_wave_pulse.svg',
            localization.find_device_screen_step3,
            1,
          ),
        },
        ConnectionState(
          'assets/icons/icon_arrow_spin.svg',
          localization.find_device_screen_step4,
          1,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    Set<int> displayedInstructionIds = {};
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final connectionState = getConnectionStates(context)[index];
          return BlocBuilder<DeviceInstructionsCubit, DeviceInstructionsState>(
            bloc: _deviceInstructionsCubit..init(),
            builder: (context, deviceInstructionsState) {
              String instructionText = '';
              
              final instructions = deviceInstructionsState.instructions ?? List.empty();
              for (var deviceInstruction in instructions) {
                if (!displayedInstructionIds.contains(deviceInstruction.id)) {
                  instructionText += deviceInstruction.instructionText + '\n';
                  displayedInstructionIds.add(deviceInstruction.id);
                  break;
                }
              }
              return Column(
                children: [
                  ConnectionLevel(
                    label: connectionState.label,
                    extraText: instructionText,
                    iconPath: connectionState.iconPath,
                    isDone: activeIndex >= connectionState.index,
                    activeIndex: activeIndex,
                    index: connectionState.index,
                  ),
                ],
              );
            },);
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
