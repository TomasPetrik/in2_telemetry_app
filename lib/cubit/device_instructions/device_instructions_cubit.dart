import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/cubit/device_instructions/device_instructions_state.dart';
import 'package:scalesoft_app/data/entities/enums/instruction_type.dart';
import 'package:scalesoft_app/data/providers/device_instruction_db_provider.dart';

@injectable
class DeviceInstructionsCubit extends Cubit<DeviceInstructionsState> {
  final DeviceInstructionDbProvider _deviceInstructionDbProvider;

    DeviceInstructionsCubit(
      this._deviceInstructionDbProvider,
    ) : super(
          DeviceInstructionsLoading(
          ),
        );

    void init(
      int prototypeId,
      InstructionType instructionType,
  ) async {
    final instructions = await _deviceInstructionDbProvider.getInstructions(prototypeId, instructionType);

    emit(
      DeviceInstructionsLoaded(
        instructions,
      ),
    );
  }
}
