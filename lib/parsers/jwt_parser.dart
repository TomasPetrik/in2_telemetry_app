import 'package:jwt_decode/jwt_decode.dart';
import 'package:scalesoft_app/parsers/user_jwt_data.dart';

class JwtParser {
  final String jwtToken;

  JwtParser({required this.jwtToken});

  List<String> getUserPermissions() {
    final payload = Jwt.parseJwt(jwtToken);

    final userJwtData = UserJwtData.fromJson(payload);
    return userJwtData.permissions;
  }
}
