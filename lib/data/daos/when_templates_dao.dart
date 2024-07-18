import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/tables/when_templates.dart';

part 'when_templates_dao.drift.dart';

@DriftAccessor(tables: [WhenTemplates])
class WhenTemplatesDao extends DatabaseAccessor<AppDatabase> with _$WhenTemplatesDaoMixin {
  WhenTemplatesDao(super.db);

  Future<List<WhenTemplate>> getByUser(int userId) async {
    return await (select(whenTemplates)..where((x) => x.userId.equals(userId))).get();
  }

  Future<void> deleteByUser(int userId) async {
    await (delete(whenTemplates)..where((x) => x.userId.equals(userId))).go();
  }

  Future<void> create(WhenTemplatesCompanion companion) async {
    await into(whenTemplates).insert(companion);
  }
}
