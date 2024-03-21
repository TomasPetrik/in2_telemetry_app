import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/hospital.dart';
import 'package:scalesoft_app/api/model/user_model.dart';
import 'package:scalesoft_app/config.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/mapper/user_mapper.auto_mappr.dart';

@injectable
@AutoMappr([
  MapType<User, UserModel>(
    fields: [
      Field('hospital', custom: UserMapper.mapHospital),
      Field.ignore('representedPeople'),
    ],
  ),
])
class UserMapper extends $UserMapper {
  static Hospital mapHospital(User user) {
    return Config.value.hospitals.firstWhere((hospital) => hospital.id == user.hospitalId);
  }
}
