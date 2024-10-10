import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/model/device_instruction_model.dart';

part 'device_instructions_state.freezed.dart';

@freezed
class DeviceInstructionsState with _$DeviceInstructionsState {
  const factory DeviceInstructionsState({
    List<DeviceInstructionModel>? instructions,
  }) = _$DeviceInstructionsStateImpl;
}
