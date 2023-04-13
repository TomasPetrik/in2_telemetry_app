import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import 'package:scalesoft_app/api/model/user_info.dart';
import 'package:scalesoft_app/utils/constants.dart';

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
