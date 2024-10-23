import 'package:scalesoft_app/model/device_instruction_model.dart';

sealed class DeviceInstructionsState {}

final class DeviceInstructionsLoading extends DeviceInstructionsState {}

final class DeviceInstructionsLoaded extends DeviceInstructionsState {
  final List<DeviceInstructionModel> instructions;

  DeviceInstructionsLoaded(this.instructions);
}
