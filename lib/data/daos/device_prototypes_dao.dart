import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/tables/device_prototypes.dart';

part 'device_prototypes_dao.drift.dart';

@DriftAccessor(tables: [DevicePrototypes])
class DevicePrototypesDao extends DatabaseAccessor<AppDatabase> with _$DevicePrototypesDaoMixin {
  DevicePrototypesDao(super.db);

  Future<int> save(DevicePrototypesCompanion prototype) async {
    return await into(devicePrototypes).insert(
      prototype,
      onConflict: DoUpdate((old) => prototype, target: []),
    );
  }

  Future<List<DevicePrototype>> getByUser(int userId) async {
    return await (select(devicePrototypes)..where((x) => x.userId.equals(userId))).get();
  }

  Future<void> removeByIds(Iterable<int> prototypeIds) async {
    await (delete(devicePrototypes)..where((x)=>x.id.isIn(prototypeIds))).go();
  }

  Future<void> updatePrototype(int prototypeId, DevicePrototypesCompanion changes) async {
    await (update(devicePrototypes)..where((x)=>x.id.equals(prototypeId))).write(changes);
  }
}
