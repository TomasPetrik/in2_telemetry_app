import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scalesoft_app/cubit/device_instructions/device_instructions_cubit.dart';
import 'package:scalesoft_app/cubit/device_instructions/device_instructions_state.dart';
import 'package:scalesoft_app/data/entities/enums/instruction_type.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/device_instruction_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/icon_label_row.dart';
import 'package:scalesoft_app/ui/widgets/rotating_icon.dart';

class DeviceProgressDetail extends StatelessWidget {
  DeviceProgressDetail({
    super.key,
    required this.device,
    required this.reqPairing,
    required this.completedIndex,
  });
  final DeviceInstructionsCubit _deviceInstructionsCubit =
      getIt<DeviceInstructionsCubit>();
  final DeviceCreateModel device;
  final bool reqPairing;
  final int completedIndex;

  List<ConnectionState> getConnectionStates(BuildContext context) {
    if (reqPairing) {
      return [
        ConnectionState(
          'assets/icons/icon_power_off.svg',
          localization.find_device_screen_step1_p(device.prototype.visibleName),
          1,
        ),
        ConnectionState(
          'assets/icons/icon_arrow_spin.svg',
          localization.find_device_screen_step3_p(
              getDeviceTypeByMeasurementType(device)),
          2,
        ),
        ConnectionState(
          'assets/icons/icon_wave_pulse.svg',
          localization.find_device_screen_step4_p(
            getDeviceTypeByMeasurementType(device),
            localization.common_action_button_label(
                device.prototype.actionButtonType!.name),
          ),
          3,
        ),
        ConnectionState(
          'assets/icons/icon_arrow_spin.svg',
          localization.find_device_screen_step5_p(
              getDeviceTypeByMeasurementType(device)),
          4,
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
            getDeviceTypeByMeasurementType(device),
            localization.common_action_button_label(
                device.prototype.actionButtonType!.name),
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
          localization
              .find_device_screen_step4(getDeviceTypeByMeasurementType(device)),
          4,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<DeviceInstructionsCubit, DeviceInstructionsState>(
        bloc: _deviceInstructionsCubit
          ..init(device.prototype.id,
              reqPairing ? InstructionType.pairing : InstructionType.measuring),
        builder: (context, deviceInstructionsState) {
          switch (deviceInstructionsState) {
            case DeviceInstructionsLoading():
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: RotatingIcon(
                    child: SvgPicture.asset(
                      'assets/icons/icon_loader.svg',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              );
            case DeviceInstructionsLoaded loadedInstructions:
              final currentIndex = completedIndex + 1;
              final connectionState = getConnectionStates(context)
                  .firstWhere((state) => state.index == currentIndex);
              DeviceInstructionModel? instruction;
              final instructions = loadedInstructions.instructions;

              for (var deviceInstruction in instructions) {
                if (deviceInstruction.index == connectionState.index) {
                  instruction = deviceInstruction;
                  break;
                }
              }
              return Column(
                children: [
                  ConnectionLevel(
                    label: connectionState.label,
                    deviceInstruction: instruction,
                    iconPath: connectionState.iconPath,
                    isDone: completedIndex >= connectionState.index,
                    completedIndex: completedIndex,
                    index: connectionState.index,
                  ),
                ],
              );
          }
        },
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
