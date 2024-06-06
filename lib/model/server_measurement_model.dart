import 'package:scalesoft_app/api/contracts/measurement/measurement_data_contract.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';

class ServerMeasurementModel {
  final DateTime measurementDateTime;
  final String formattedValue;
  final MeasurementType measurementType;
  final int userId;

  const ServerMeasurementModel({
    required this.measurementDateTime,
    required this.formattedValue,
    required this.measurementType,
    required this.userId,
  });

  static ServerMeasurementModel fromContract(
    MeasurementDataContract contract,
    int userId,
    MeasurementType measurementType,
  ) {
    return ServerMeasurementModel(
      measurementDateTime: contract.measurementDateTime,
      formattedValue: contract.getFormattedValue(),
      measurementType: measurementType,
      userId: userId,
    );
  }
}
