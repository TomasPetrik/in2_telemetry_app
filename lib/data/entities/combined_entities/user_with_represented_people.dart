import 'package:scalesoft_app/data/app_database.dart';

class UserWithRepresentedPeople {
  final User rootUser;
  final List<User> representedPeople;

  UserWithRepresentedPeople({required this.rootUser, required this.representedPeople});
}
