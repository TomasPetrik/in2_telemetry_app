import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/auth_token.dart';
import 'package:scalesoft_app/api/dto/hospital.dart';
import 'package:scalesoft_app/model/user_account.dart';

@singleton
class Session {
  AuthToken? token;
  List<UserPermission>? userPermissions;
  Hospital? hospital;
  UserAccount? userAccount;
}
