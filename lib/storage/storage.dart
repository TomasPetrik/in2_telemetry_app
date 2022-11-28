import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/api/dto/user_info.dart';

@singleton
class Storage {
  final FlutterSecureStorage _secureStorage;

  final _accessTokenKey = 'accesshToken';
  final _refreshTokenKey = 'refreshToken';

  AuthToken? token;
  UserInfo? userInfo;

  Storage(this._secureStorage);

  Future<String?> getRefreshToken(String userId) async {
    final tokenString = await _secureStorage.read(key: '${_refreshTokenKey}_$userId');
    return tokenString;
  }

  Future<void> setRefreshToken(String userId, String token) {
    return _secureStorage.write(key: '${_refreshTokenKey}_$userId', value: token);
  }

  Future<void> removeTokens(String userId) {
    return _secureStorage
        .delete(
          key: '${_accessTokenKey}_$userId',
        )
        .then(
          (value) => _secureStorage.delete(key: '${_refreshTokenKey}_$userId'),
        );
  }

  Future<void> setAuthToken(String userId, AuthToken authToken) async {
    await setRefreshToken(userId, authToken.refreshToken);
    return;
  }
}
