import 'package:json_annotation/json_annotation.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:scalesoft_app/parsers/user_jwt_data.dart';

class JwtParser {
  final String jwtToken;

  JwtParser({required this.jwtToken});

  List<UserPermission> getUserPermissions() {
    final payload = Jwt.parseJwt(jwtToken);

    final originalPermissions =
        List<String>.from(payload['permission'] as List);
    final filteredPremissions = originalPermissions
        .where((permission) => supportedUserPermissions.contains(permission))
        .toList();

    payload['permission'] = filteredPremissions;

    final userJwtData = UserJwtData.fromJson(payload);
    return userJwtData.permission;
  }
}

enum UserPermission {
  @JsonValue('scs-can-manually-enter-measurement')
  canManuallyEnterMeasurement('scs-can-manually-enter-measurement'),
  @JsonValue('scs-view-own-measurement-data')
  viewOwnMeasurementData('scs-view-own-measurement-data'),
  @JsonValue('scs-enter-measurement-without-plan')
  enterMeasurementWithoutPlan('scs-enter-measurement-without-plan');

  const UserPermission(this.key);

  final String key;
}

const supportedUserPermissions = [
  'scs-can-manually-enter-measurement',
  'scs-view-own-measurement-data',
  'scs-enter-measurement-without-plan'
];
