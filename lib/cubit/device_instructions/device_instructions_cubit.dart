import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/cubit/device_instructions/device_instructions_state.dart';
import 'package:scalesoft_app/data/providers/device_instruction_db_provider.dart';
import 'package:scalesoft_app/model/device_instruction_model.dart';

@injectable
class DeviceInstructionsCubit extends Cubit<DeviceInstructionsState> {
  final DeviceInstructionDbProvider _deviceInstructionDbProvider;

    DeviceInstructionsCubit(
      this._deviceInstructionDbProvider,
    ) : super(
          const DeviceInstructionsState(
            instructions: null,
          ),
        );

  Future<List<DeviceInstructionModel>> getDeviceInstructions(int prototypeId, bool isPairing) async {
    final deviceInstructions = await _deviceInstructionDbProvider.getInstructions(prototypeId, isPairing);
    return deviceInstructions.toList();
  }

    void init(
      int prototypeId,
      bool isPairing
  ) async {
    final instructions = await getDeviceInstructions(prototypeId, isPairing);

    emit(
      DeviceInstructionsState(
        instructions: instructions,
      ),
    );
  }
}
