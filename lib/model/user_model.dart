import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/measurement_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/time_setting.dart';
import 'package:scalesoft_app/model/enum/user_problem_type.dart';
import 'package:scalesoft_app/model/hospital.dart';

class UserModel {
  final int id;
  final int? parentId;
  List<UserModel> representedPeople;
  final Hospital hospital;
  final String muid;
  final String firstNames;
  final String lastNames;
  final List<String> phoneNumbers;
  final List<String> emailAddresses;
  final DateTime? lastActive;
  final AuthToken authToken;
  final List<String> permissions;
  final bool isSessionExpired;
  final DateTime lastSyncAt;
  final bool lastSyncFailed;
  final List<int> notificationIds;
  final List<TimeSetting> timeSettings;
  UserProblemType? problem;
  final MeasurementThresholds? thresholds;

  UserModel({
    required this.id,
    this.parentId,
    required this.representedPeople,
    required this.hospital,
    required this.muid,
    required this.firstNames,
    required this.lastNames,
    required this.phoneNumbers,
    required this.emailAddresses,
    this.lastActive,
    required this.authToken,
    required this.permissions,
    required this.isSessionExpired,
    required this.lastSyncAt,
    required this.lastSyncFailed,
    required this.notificationIds,
    required this.timeSettings,
    this.problem,
    this.thresholds,
  });

  bool get isRepresentedPerson => parentId != null;

  String get fullName {
    final buffer = StringBuffer();

    if (firstNames.isNotEmpty) {
      buffer.write(firstNames);
    }

    if (firstNames.isNotEmpty && lastNames.isNotEmpty) {
      buffer.write(' ');
    }

    if (lastNames.isNotEmpty) {
      buffer.write(lastNames);
    }

    return buffer.toString();
  }

  // hash needs two input parameters, but we only care about the id.
  @override
  int get hashCode => Object.hash(id, id);

  @override
  bool operator ==(Object other) {
    if (other is! UserModel) {
      return false;
    }
    return id == other.id;
  }
}
