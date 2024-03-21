import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';

@injectable
class LogDbProvider {
  final AppDatabase _database;

  LogDbProvider(this._database);

  Future<int> save(
    int? userId,
    LogSeverity severity,
    String message,
    DateTime eventTime,
    String appVersion,
    String osVersion,
  ) async {
    final log = LogEventsCompanion.insert(
      userId: Value(userId),
      eventTime: DateTime.now(),
      appVersion: appVersion,
      osVersion: osVersion,
      severity: severity,
      message: message,
    );

    return await _database.logsDao.save(log);
  }

  Future<Map<String?, List<LogEvent>>> getLogEventsPerUser() async {
    final entities = await _database.logsDao.getAll();

    Map<String?, List<LogEvent>> result = entities.groupFoldBy((x) => x.muid, (prev, curr) => [...?prev, curr.log]);
    return result;
  }

  Future<void> removeBeforeDateTime(DateTime date) async {
    await _database.logsDao.removeBeforeDateTime(date);
  }
}
