import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/device/device_instruction_contract.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/model/device_prototype_model.dart';

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
        id: Value(contract.id),
        prototypeId: contract.devicePrototypeId,
        index: contract.id,
        languageCode: contract.languageCode,
        instructionType: contract.instructionType,
        lastModifiedTime: Value(contract.lastModifiedTime),
        instructionText: Value(contract.text),
        image: contract.base64Image != null 
          ? Value(base64Decode(contract.base64Image!)) 
          : Value(Uint8List(0))
      );

      await _database.deviceInstructionsDao.save(companion);
    }
  }

  Future<List<DevicePrototypeModel>> getByUser(int userId) async {
    final entities = await _database.devicePrototypesDao.getByUser(userId);

    return entities.map(DevicePrototypeModel.fromEntity).toList();
  }
}
