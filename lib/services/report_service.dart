import 'dart:io';
import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scalesoft_app/api/contracts/logs/logs_contract.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/data/providers/log_db_provider.dart';
import 'package:scalesoft_app/mapper/log_event_mapper.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';

@preResolve
@lazySingleton
class ReportService {
  final LogDbProvider _logsDbProvider;
  final AccountRepository _accountRepository;
  final LogEventMapper _logEventMapper;

  final String _appVersion;
  final String _phoneModel;
  final String _osVersion;
  final String _appIdentifier;

  ReportService._(
    this._logsDbProvider,
    this._accountRepository,
    this._appVersion,
    this._phoneModel,
    this._osVersion,
    this._appIdentifier,
    this._logEventMapper,
  );

  @factoryMethod
  static Future<ReportService> create(
    final LogDbProvider logDbProvider,
    final AccountRepository accountRepository,
    final LogEventMapper logEventMapper,
  ) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = packageInfo.version;
    final String phoneModel;
    final String osVersion;
    final String appIdentifier;

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      phoneModel = iosInfo.utsname.machine;
      osVersion = iosInfo.systemVersion;
      appIdentifier = iosInfo.identifierForVendor ?? 'unknowId';
    } else {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      phoneModel = androidInfo.model;
      osVersion = androidInfo.version.release;
      appIdentifier = androidInfo.serialNumber;
    }

    debugPrint('pre resolving report service, appVersion: $appVersion');

    final instance = ReportService._(
      logDbProvider,
      accountRepository,
      appVersion,
      phoneModel,
      osVersion,
      appIdentifier,
      logEventMapper,
    );

    return instance;
  }

  /*
    1. Some events can be related to a specific user directly,
    2. Other not user-related events will be automatically added to most recent active user in future
  */
  Future<void> trackEvent({
    int? userId,
    required LogSeverity severity,
    required String message,
  }) async {
    await _logsDbProvider.save(userId, severity, message, DateTime.now(), _appVersion, _osVersion);
  }

  Future<void> removeOldLogs() async {
    final dtNow = DateTime.now();
    final dtOfRemoval = dtNow.subtract(const Duration(days: ConfigurationConstants.keepLogsDays));

    await _logsDbProvider.removeBeforeDateTime(dtOfRemoval);
  }

  Future<void> syncReports() async {
    final reports = await _logsDbProvider.getLogEventsPerUser();

    // Some reports don't have a user ID attached (logout, etc.). Attach those events to another user.
    final fallbackUserId = reports.keys.lastWhereOrNull((x) => x != null);

    try {
      for (final userReports in reports.entries) {
        final userId = userReports.key ?? fallbackUserId;
        if (userId == null) {
          continue;
        }

        final contract = LogsContract(
          appIdentifier: _appIdentifier,
          phoneModel: _phoneModel,
          logs: _logEventMapper.convertList(userReports.value),
        );

        await _accountRepository.sendUserAppReports(
          userId: userId,
          reportRequest: contract,
        );

        // Delete by userReports key instead of userId to avoid deleting another user's logs
        // (in case userReports.key is null)
        await _logsDbProvider.deleteUserReports(userReports.key);
      }
    } catch (_) {
      rethrow;
    }
  }
}
