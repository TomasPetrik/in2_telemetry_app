import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/device/device_instruction_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/model/device_instruction_model.dart';

@injectable
class DeviceInstructionDbProvider {
  final AppDatabase _database;

  DeviceInstructionDbProvider(
    this._database,
  );

  Future<void> replaceDeviceInstructions(List<DeviceInstructionContract> newInstructions) async {
    await _database.deviceInstructionsDao.removeDeviceInstructions();

    for (final contract in newInstructions) {
      final companion = DeviceInstructionsCompanion.insert(
        remoteId: contract.id,
        prototypeId: contract.devicePrototypeId,
        index: contract.id,
        languageCode: contract.languageCode,
        instructionType: contract.instructionType,
        lastModifiedTime: contract.lastModifiedTime,
        instructionText: contract.text,
        image: contract.base64Image != null 
          ? Value(base64Decode(contract.base64Image!.split(',')[1])) 
          : Value(Uint8List(0)),
      );

      await _database.deviceInstructionsDao.save(companion);
    }
  }

  Future<List<DeviceInstructionModel>> getInstructions(int prototypeId, bool isPairing) async {
    final entities = await _database.deviceInstructionsDao.getInstructions(prototypeId, isPairing);

    return entities.map(DeviceInstructionModel.fromEntity).toList();
  }
}
