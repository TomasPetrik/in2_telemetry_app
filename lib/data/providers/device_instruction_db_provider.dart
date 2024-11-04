import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/device/device_instruction_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/instruction_type.dart';
import 'package:scalesoft_app/model/device_instruction_model.dart';

@injectable
class DeviceInstructionDbProvider {
  final AppDatabase _database;

  DeviceInstructionDbProvider(
    this._database,
  );

  Future<void> replaceDeviceInstructions(List<DeviceInstructionContract> newInstructions, int userId) async {
    await _database.deviceInstructionsDao.removeDeviceInstructions(userId);
    for (final contract in newInstructions) {
      final prototype = await _database.devicePrototypesDao.getByRemotePrototypeId(contract.devicePrototypeId, userId);
      final companion = DeviceInstructionsCompanion.insert(
        remoteId: contract.id,
        prototypeId: prototype.id,
        userId: userId,
        index: contract.index,
        languageCode: contract.languageCode,
        instructionType: contract.instructionType,
        lastModifiedTime: contract.lastModifiedTime,
        instructionText: contract.text,
        image: contract.base64Image != null 
          ? Value(base64Decode(contract.base64Image!))
          : Value(Uint8List(0)),
      );

      await _database.deviceInstructionsDao.save(companion);
    }
  }

  Future<List<DeviceInstructionModel>> getInstructions(int prototypeId, InstructionType instructionType) async {
    final entities = await _database.deviceInstructionsDao.getInstructions(prototypeId, instructionType);

    return entities.map(DeviceInstructionModel.fromEntity).toList();
  }
}
