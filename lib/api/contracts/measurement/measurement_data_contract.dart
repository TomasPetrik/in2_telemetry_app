import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/api/contracts/measurement/composed_value_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/overall_health_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/shortness_of_breath_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

part 'measurement_data_contract.g.dart';


@JsonSerializable()
class MeasurementDataContract {
  @JsonKey(fromJson: toLocalDate)
  final DateTime measurementDateTime;
  final double? value;
  final ComposedValueContract? composedValue;

  @JsonKey(name: 'type')
  final MeasurementTypeContract measurementType;

  const MeasurementDataContract({
    required this.measurementDateTime,
    this.value,
    this.composedValue,
    required this.measurementType,
  });

  factory MeasurementDataContract.fromJson(Map<String, dynamic> json) => _$MeasurementDataContractFromJson(json);

  @override
  String toString() => _$MeasurementDataContractToJson(this).toString();


  String getFormattedValue() {
    final stringValue = switch (measurementType) {
      MeasurementTypeContract.temperature => value?.toStringAsFixed(1),
      MeasurementTypeContract.bloodPressure =>
      "${composedValue?.firstValue?.toStringAsFixed(0) ?? '?'}/${composedValue?.secondValue?.toStringAsFixed(0) ??
          '?'}",
      MeasurementTypeContract.oxygenSaturation ||
      MeasurementTypeContract.heartRate ||
      MeasurementTypeContract.respiratoryRate ||
      MeasurementTypeContract.ews =>
          value?.toInt().toString(),
      MeasurementTypeContract.shortnessOfBreath =>
      value != null
          ? localization.shortness_of_breath_values(
        ShortnessOfBreathContract.values.firstWhere((x) => x.value == value!.toInt()),
      )
          : "",
      MeasurementTypeContract.overallHealth =>
      value != null
          ? localization.overall_health_values(
        OverallHealthContract.values.firstWhere((x) => x.value == value!.toInt()),
      )
          : "",
      MeasurementTypeContract.steps || MeasurementTypeContract.globalPosition || MeasurementTypeContract.battery => "",
    };

    return "$stringValue ${localization.common_measurement_units_types(measurementType)}";
  }
}