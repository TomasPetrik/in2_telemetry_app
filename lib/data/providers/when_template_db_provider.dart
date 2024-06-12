import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/time_settings/when_setting_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/when_code.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/time_only.dart';
import 'package:scalesoft_app/mapper/when_code_mapper.dart';

@injectable
class WhenTemplateDbProvider {
  final AppDatabase _database;
  final WhenCodeMapper _whenCodeMapper;

  WhenTemplateDbProvider(this._database, this._whenCodeMapper);

  Future<List<WhenTemplate>> getByUser(int userId) async {
    return await _database.whenTemplatesDao.getByUser(userId);
  }

  Future<void> replaceUserTemplates(int userId, List<WhenSettingContract> contracts) async {
    await _database.whenTemplatesDao.deleteByUser(userId);
    for (final contract in contracts) {
      final WhenCode whenCode = _whenCodeMapper.convert(contract.codeValue);
      final start = TimeOnly.fromString(contract.start);
      final end = TimeOnly.fromString(contract.end);
      final userEditMin = contract.userEditMin == null ? null : TimeOnly.fromString(contract.userEditMin!);
      final userEditMax = contract.userEditMax == null ? null : TimeOnly.fromString(contract.userEditMax!);

      final companion = WhenTemplatesCompanion.insert(
        userId: userId,
        whenCode: whenCode,
        start: start,
        end: end,
        userEditMin: Value(userEditMin),
        userEditMax: Value(userEditMax),
      );
      await _database.whenTemplatesDao.create(companion);
    }
  }
}
