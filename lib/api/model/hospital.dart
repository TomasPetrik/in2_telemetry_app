import 'package:scalesoft_app/api/model/auth_data.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';

class Hospital {
  final int id;
  final String title;
  final String iconPath;
  final AuthData authData;
  final List<MeasurementType> enabledMeasurementTypes;

  const Hospital({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.authData,
    required this.enabledMeasurementTypes,
  });
}
