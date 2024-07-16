import 'package:scalesoft_app/api/model/auth_data.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';

class Hospital {
  final int id;
  final String title;
  final String iconPath;
  final AuthData authData;
  final List<MeasurementType> enabledMeasurementTypes;
  final String clientSecret;
  final bool isStaging;

  const Hospital({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.authData,
    required this.enabledMeasurementTypes,
    required this.clientSecret,
    this.isStaging = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Hospital && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "Hospital $title, id:$id, measurementTypes:$enabledMeasurementTypes";
  }
}
