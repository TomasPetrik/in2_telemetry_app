import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/data/app_database.dart';

@injectable
class WhenTemplateDbProvider {
  final AppDatabase _database;

  WhenTemplateDbProvider(this._database);

  Future<List<WhenTemplate>> getByUser(int userId) async {
    return await _database.whenTemplatesDao.getByUser(userId);
  }
}
