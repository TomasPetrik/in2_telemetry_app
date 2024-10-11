import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/device/device_prototype_contract.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/model/device_prototype_model.dart';

@injectable
class DevicePrototypeDbProvider {
  final AppDatabase _database;

  DevicePrototypeDbProvider(
    this._database,
  );

  Future<void> replaceUserPrototypes(
    int userId,
    List<DevicePrototypeContract> remotePrototypes,
  ) async {
    final remoteIds = remotePrototypes.map((x) => x.id);

    final existingPrototypes =
        await _database.devicePrototypesDao.getByUser(userId);
    final existingPrototypeRemoteIds = existingPrototypes.map((x) => x.remoteId);
    final obsoletePrototypes = existingPrototypes
        .where(
          (existingPrototype) =>
              !remoteIds.contains(existingPrototype.remoteId),
        )
        .map((x) => x.id);

    await _database.devicePrototypesDao.removeByIds(obsoletePrototypes);

    final prototypesToUpdate = remotePrototypes.where(
      (remotePrototype) =>
          existingPrototypeRemoteIds.contains(remotePrototype.id),
    );
    for (final contract in prototypesToUpdate) {
      final existing =
          existingPrototypes.firstWhere((x) => x.remoteId == contract.id);

      final changes = DevicePrototypesCompanion(
        aboutUrl: Value(contract.aboutUrl),
      );

      await _database.devicePrototypesDao.updatePrototype(existing.id, changes);
    }

    final prototypesToCreate = remotePrototypes.where(
      (remotePrototype) =>
          !existingPrototypeRemoteIds.contains(remotePrototype.id),
    );

    for (final contract in prototypesToCreate) {
      final template = ConfigurationConstants.supportedDevices.firstWhereOrNull(
        (x) =>
            x.deviceManufacturer == contract.manufacturer &&
            x.modelName == contract.modelName,
      );
      if (template == null) {
        continue;
      }

      final companion = DevicePrototypesCompanion.insert(
        userId: userId,
        remoteId: contract.id,
        templateData: template,
        aboutUrl: Value(contract.aboutUrl),
      );

      await _database.devicePrototypesDao.save(companion);
    }
  }

  Future<List<DevicePrototypeModel>> getByUser(int userId) async {
    final entities = await _database.devicePrototypesDao.getByUser(userId);

    return entities.map(DevicePrototypeModel.fromEntity).toList();
  }
}
