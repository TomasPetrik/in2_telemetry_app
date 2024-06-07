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

  Future<void> replaceUserPrototypes(int userId, List<DevicePrototypeContract> newPrototypes) async {
    await _database.devicePrototypesDao.removeUserPrototypes(userId);

    for (final contract in newPrototypes) {
      final template = ConfigurationConstants.supportedDevices
          .firstWhereOrNull((x) => x.deviceManufacturer == contract.manufacturer && x.modelName == contract.modelName);
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

    return entities.map(_fromEntity).toList();
  }

  DevicePrototypeModel _fromEntity(DevicePrototype entity) {
    return DevicePrototypeModel(
      entity.templateData.localId,
      entity.templateData.modelName,
      entity.templateData.deviceManufacturer,
      entity.templateData.visibleName,
      entity.templateData.bluetoothName,
      entity.templateData.bluetoothPairingName,
      entity.templateData.deviceModelType,
      entity.userId,
      entity.templateData.supportedMeasurementTypes,
      entity.templateData.requiresPairing,
      entity.templateData.askToActivateBt,
      entity.templateData.askToConfirmMeasurement,
      entity.templateData.imagePath,
      entity.templateData.measurementFlow,
      entity.templateData.actionButtonType,
      entity.remoteId,
      aboutUrl: entity.aboutUrl,
    );
  }
}
