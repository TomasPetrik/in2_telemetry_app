import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement_result.dart';
import 'package:scalesoft_app/api/dto/user.dart';

part 'user_account.freezed.dart';
part 'user_account.g.dart';

@unfreezed
class UserAccount with _$UserAccount {
  const UserAccount._();

  @HiveType(typeId: 2, adapterName: 'UserAccountAdapter')
  factory UserAccount({
    @HiveField(0) required User user,
    @HiveField(1) AuthToken? authToken,
    @HiveField(2) List<UserPermission>? userPermissions,
    @HiveField(3) Hospital? hospital,
    @HiveField(4) DateTime? signedIn,
    @HiveField(5) DateTime? lastActiveIn,
    @HiveField(6) List<UserAccount>? representedPeople,
    @HiveField(7) String? parentId,
    @HiveField(8) List<CarePlan>? carePlans,
    @HiveField(9) bool? sessionExpired,
    @HiveField(10) List<MeasurementResult>? measurementResults,
    @HiveField(11) DateTime? lastSyncAt,
    @HiveField(12) bool? lastSyncFailed,
  }) = _UserAccount;

  factory UserAccount.fromJson(Map<String, dynamic> json) =>
      _$UserAccountFromJson(json);

  @override
  String toString() => toJson().toString();

  UserProblemType? getProblemIfExists() {
    if (sessionExpired == true) {
      return UserProblemType.sessionExpired;
    }

    if (lastSyncFailed == true) {
      return UserProblemType.lastSyncFailed;
    }

    if (carePlans?.any((carePlan) => carePlan.wasChanged == true) == true) {
      return UserProblemType.carePlanUpdated;
    }

    return null;
  }

  bool get enterMeasurementWithoutPlan =>
      userPermissions?.contains(
        UserPermission.enterMeasurementWithoutPlan,
      ) ==
      true;

  bool get viewOwnMeasurementData =>
      userPermissions?.contains(
        UserPermission.viewOwnMeasurementData,
      ) ==
      true;

  bool get canManuallyEnterMeasurement =>
      userPermissions?.contains(
        UserPermission.canManuallyEnterMeasurement,
      ) ==
      true;
}

enum UserProblemType {
  sessionExpired,
  lastSyncFailed,
  carePlanUpdated,
  syncResultsFailed,
}

@HiveType(typeId: 6)
enum UserPermission {
  @JsonValue('scs-can-manually-enter-measurement')
  @HiveField(0)
  canManuallyEnterMeasurement,
  @JsonValue('scs-view-own-measurement-data')
  @HiveField(1)
  viewOwnMeasurementData,
  @JsonValue('scs-enter-measurement-without-plan')
  @HiveField(2)
  enterMeasurementWithoutPlan;
}

const supportedUserPermissions = [
  'scs-can-manually-enter-measurement',
  'scs-view-own-measurement-data',
  'scs-enter-measurement-without-plan'
];
