import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/configuration/hospitals_configuration.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/mapper/user_mapper.auto_mappr.dart';
import 'package:scalesoft_app/model/hospital.dart';
import 'package:scalesoft_app/model/user_model.dart';

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
    return HospitalsConfiguration.hospitals.firstWhere((hospital) => hospital.id == user.hospitalId);
  }
}
