import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class HospitalDbProvider extends BoxProvider<Hospital> {
  @override
  @PostConstruct(preResolve: true)
  Future<void> init() async => super.init();

  @override
  final String boxName = 'HospitalBox';

  @override
  void registerAdapters() {}

  Hospital? read() {
    try {
      if (box.isNotEmpty) {
        final local = box.values.first;

        return local;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> write(Hospital hospital) async {
    await box.clear();
    box.add(hospital);
  }
}
