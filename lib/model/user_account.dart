import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/auth_token.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan.dart';
import 'package:scalesoft_app/api/model/device_model.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/measurement/measurement_result.dart';
import 'package:scalesoft_app/api/model/settings/time_setting.dart';
import 'package:scalesoft_app/api/model/template_time_set.dart';
import 'package:scalesoft_app/api/model/user.dart';

part 'user_account.freezed.dart';
part 'user_account.g.dart';
part 'user_account.hive.dart';

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
    @HiveField(13) List<Device>? assignedDevices,
    @HiveField(14) TemplateTimeSet? templateTimeSet,
    @HiveField(15) List<TimeSetting>? timeSettingItems,
    @HiveField(16) List<DeviceModel>? supportedDeviceModels,
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

  bool get canManageTelemonitoringDevices =>
      userPermissions?.contains(
        UserPermission.canManageTelemonitoringDevices,
      ) ==
      true;

  bool get canMeasureWithUnknowDevice =>
      userPermissions?.contains(
        UserPermission.canMeasureWithUnknowDevice,
      ) ==
      true;

  bool canMeasureWithDeviceId(String deviceIdentifier) {
    final foundDevice = assignedDevices?.firstWhereOrNull(
      (dev) =>
          dev.deviceIdentifier?.toLowerCase() == deviceIdentifier.toLowerCase(),
    );
    return foundDevice != null;
  }
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
  enterMeasurementWithoutPlan,
  @JsonValue('scs-can-manage-telemonitoring-devices')
  @HiveField(3)
  canManageTelemonitoringDevices,
  @JsonValue('scs-measure-with-unknown-device')
  @HiveField(4)
  canMeasureWithUnknowDevice,
}

const supportedUserPermissions = [
  'scs-can-manually-enter-measurement',
  'scs-view-own-measurement-data',
  'scs-enter-measurement-without-plan',
  'scs-can-manage-telemonitoring-devices',
  'scs-measure-with-unknown-device',
];
