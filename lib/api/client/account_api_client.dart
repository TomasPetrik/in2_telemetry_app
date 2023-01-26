import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/dto/user_info.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';

part 'account_api_client.g.dart';

@RestApi()
@injectable
abstract class AccountApiClient {
  @factoryMethod
  factory AccountApiClient(@Named(Constants.privateDioName) Dio dio) =
      _AccountApiClient;

  @GET('/user/me')
  Future<UserInfo> loadUserInfo();
}
