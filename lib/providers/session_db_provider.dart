import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class SessionDbProvider extends BoxProvider<bool> {
  @override
  final String boxName = 'sessionBox';

  @override
  void registerAdapters() {}

  bool isMultiUser() {
    if (box.isNotEmpty) {
      final local = box.values.first;

      return local;
    }
    return false;
  }

  Future<bool> setIsMultiUser(bool isMultiUser) async {
    await box.clear();
    box.add(isMultiUser);
    return isMultiUser;
  }
}
