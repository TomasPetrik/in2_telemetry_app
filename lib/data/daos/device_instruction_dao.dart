import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/instruction_type.dart';
import 'package:scalesoft_app/data/tables/device_instructions.dart';

part 'device_instruction_dao.drift.dart';

@DriftAccessor(tables: [DeviceInstructions])
class DeviceInstructionsDao extends DatabaseAccessor<AppDatabase> with _$DeviceInstructionsDaoMixin {
  DeviceInstructionsDao(super.db);

  Future<void> removeDeviceInstructions(int userId) async {
    await (delete(deviceInstructions)..where((x) => x.userId.equals(userId))).go();
  }

  Future<int> save(DeviceInstructionsCompanion instruction) async {
    return await into(deviceInstructions).insert(
      instruction,
      onConflict: DoUpdate((old) => instruction, target: []),
    );
  }

  Future<List<DeviceInstruction>> getInstructions(int prototypeId, InstructionType instructionType) async {
    final query = select(deviceInstructions)..where((x) => x.prototypeId.equals(prototypeId) & (x.instructionType.equals(instructionType.name)));

    return query.get();
  }
}
