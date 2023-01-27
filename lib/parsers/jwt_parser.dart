import 'package:jwt_decode/jwt_decode.dart';
import 'package:scalesoft_app/model/user_account.dart';
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
