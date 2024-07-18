import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/logs/log_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/mapper/log_event_mapper.auto_mappr.dart';

@injectable
@AutoMappr(
  [
    MapType<LogEvent, LogContract>(),
    MapType<LogSeverity, Severity>(),
  ],
)
class LogEventMapper extends $LogEventMapper {}
