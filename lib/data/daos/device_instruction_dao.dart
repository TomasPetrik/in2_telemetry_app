import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/tables/device_instructions.dart';

part 'device_instruction_dao.drift.dart';

@DriftAccessor(tables: [DeviceInstructions])
class DeviceInstructionsDao extends DatabaseAccessor<AppDatabase> with _$DeviceInstructionsDaoMixin {
  DeviceInstructionsDao(super.db);

  Future<void> removeDeviceInstructions() async {
    await (delete(deviceInstructions).go());
  }

  Future<int> save(DeviceInstructionsCompanion instruction) async {
    return await into(deviceInstructions).insert(
      instruction,
      onConflict: DoUpdate((old) => instruction, target: []),
    );
  }

  Future<List<DeviceInstruction>> getInstructions(int prototypeId, bool isPairing) async {
    final query = select(deviceInstructions)..where((x) => x.prototypeId.equals(prototypeId));

    if (isPairing) {
      query.where((x) => x.instructionType.equals("Pairing"));
    } else {
      query.where((x) => x.instructionType.equals("Measuring"));
    }
    return query.get();
  }
}
