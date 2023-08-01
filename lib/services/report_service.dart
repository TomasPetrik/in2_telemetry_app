import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scalesoft_app/api/model/report/report.dart';
import 'package:scalesoft_app/api/model/report/report_request.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/reports_db_provider.dart';
import 'package:scalesoft_app/repositories/account_repository.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:unique_identifier/unique_identifier.dart';

@preResolve
@lazySingleton
class ReportService {
  final AccountDbProvider _accountDbProvider;
  final ReportsDbProvider _reportsDbProvider;
  final AccountRepository _accountRepository;

  final String _appVersion;
  final String _phoneModel;
  final String _osVersion;
  final String _appIdentifier;

  ReportService._(
    this._accountDbProvider,
    this._reportsDbProvider,
    this._accountRepository,
    this._appVersion,
    this._phoneModel,
    this._osVersion,
    this._appIdentifier,
  );

  @factoryMethod
  static Future<ReportService> create(
    final AccountDbProvider accountDbProvider,
    final ReportsDbProvider reportsDbProvider,
    final AccountRepository accountRepository,
  ) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = packageInfo.version;
    final String phoneModel;
    final String osVersion;
    final String appIdentifier;
    final String? identifier = await UniqueIdentifier.serial;

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      phoneModel = iosInfo.utsname.machine;
      osVersion = iosInfo.systemVersion;
      appIdentifier = identifier ?? iosInfo.identifierForVendor ?? 'unknowId';
    } else {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      phoneModel = androidInfo.model;
      osVersion = androidInfo.version.release;
      appIdentifier = identifier ?? androidInfo.serialNumber;
    }

    debugPrint('pre resolving report service, appVersion: $appVersion');

    final instance = ReportService._(
      accountDbProvider,
      reportsDbProvider,
      accountRepository,
      appVersion,
      phoneModel,
      osVersion,
      appIdentifier,
    );

    return instance;
  }

  Future<void> trackEvent(
    UserAccount userAccount,
    Severity severity,
    String message,
  ) async {
    final report = Report(
      eventTime: DateTime.now(),
      appVersion: _appVersion,
      phoneModel: _phoneModel,
      osVersion: _osVersion,
      severity: severity,
      patientMuid: userAccount.user.muid,
      message: message,
    );
    _reportsDbProvider.save(report);
  }

  Future<void> removeOldLogs() async {
    final dtNow = DateTime.now();
    final dtOfRemoval =
        dtNow.subtract(const Duration(days: Constants.keepLogsDays));

    await _reportsDbProvider.removeBeforeDateTime(dtOfRemoval);
  }

  Future<void> syncReports() async {
    final List<UserAccount> userAccounts = _accountDbProvider.getAll();

    try {
      for (final userAccount in userAccounts) {
        final userReports =
            _reportsDbProvider.getPerUser(userAccount.user.muid);
        if (userReports.isEmpty) {
          continue;
        }

        final reportRequest =
            ReportRequest(appIdentifier: _appIdentifier, logs: userReports);

        await _accountRepository.sendUserAppReports(
          userAccount: userAccount,
          reportRequest: reportRequest,
        );

        await _reportsDbProvider.removeUserReports(userAccount.user.muid);
      }
    } catch (_) {
      rethrow;
    }
  }
}
