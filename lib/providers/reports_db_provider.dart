import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/report/report.dart';
import 'package:scalesoft_app/api/model/report/report_request.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class ReportsDbProvider extends BoxProvider<Report> {
  @override
  @PostConstruct(preResolve: true)
  Future<void> init() async => super.init();

  @override
  final String boxName = 'reportsBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(ReportAdapter());
    Hive.registerAdapter(SeverityAdapter());
    Hive.registerAdapter(ReportRequestAdapter());
  }

  List<Report> getAll() {
    if (box.isNotEmpty) {
      return box.values.toList();
    }
    return [];
  }

  Future<int> removeAll() async {
    return box.clear();
  }

  List<Report> getPerUser(String userId) {
    if (box.isNotEmpty) {
      return box.values
          .where((report) => report.patientMuid == userId)
          .toList();
    }
    return [];
  }

  Report? getAt(final int index) {
    return box.getAt(index);
  }

  Future<Report> save(
    final Report report,
  ) async {
    await box.put(
      '${report.eventTime!.millisecondsSinceEpoch}',
      report,
    );

    final patientMuid = report.patientMuid;
    if (patientMuid != null) {
      //also assign previously unassigned events to hospital enviroment of current user
      final unassignedReports =
          box.values.where((report) => report.patientMuid == null);
      for (final report in unassignedReports) {
        await box.put(
          '${report.eventTime!.millisecondsSinceEpoch}',
          report.copyWith(patientMuid: patientMuid),
        );
      }
    }
    return report;
  }

  Future<Report> remove(
    final Report report,
  ) async {
    final reportId = report.eventTime!.millisecondsSinceEpoch;
    await box.delete('$reportId');
    return report;
  }

  Future<void> removeByDateTime(
    final DateTime reportDateTime,
  ) async {
    await box.delete('${reportDateTime.millisecondsSinceEpoch}');
  }

  Future<void> removeBeforeDateTime(
    final DateTime dateTime,
  ) async {
    for (final reportKey in box.keys) {
      final reportDt =
          DateTime.fromMillisecondsSinceEpoch(int.parse(reportKey));
      if (reportDt.isBefore(dateTime)) {
        box.delete(reportKey);
      }
    }
  }

  Future<void> removeUserReports(
    final String userId,
  ) async {
    final userReports = getPerUser(userId);
    for (final userReport in userReports) {
      await remove(userReport);
    }
  }
}
