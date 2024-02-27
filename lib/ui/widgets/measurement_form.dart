import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/contracts/measurement/blood_pressure_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement.dart';
import 'package:scalesoft_app/api/contracts/measurement/overall_health_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/shortness_of_breath_contract.dart';
import 'package:scalesoft_app/model/measurement_config.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/scale_select_form_field.dart';
import 'package:scalesoft_app/ui/widgets/scale_text_form_field.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/utils/extensions/string_extensions.dart';

final formKey = GlobalKey<FormState>();
final List<GlobalKey<FormState>> fieldGlobalKeys = [
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
];

class MeasurementForm extends StatelessWidget {
  MeasurementForm({
    super.key,
    required this.measurementType,
    required this.userId,
  });

  final MeasurementTypeContract measurementType;
  final String userId;

  double? _value1;
  double? _value2;

  Measurement? getMeasurement() {
    if (formKey.currentState?.validate() == true) {
      Measurement? measurement = Measurement(
        patientMuid: userId,
        measurementType: measurementType,
      );
      switch (measurementType) {
        case MeasurementTypeContract.temperature:
          return measurement.copyWith(
            temperature: _value1,
          );
        case MeasurementTypeContract.bloodPressure:
          return measurement.copyWith(
            bloodPressure: _value1 == null || _value2 == null
                ? null
                : BloodPressureContract(
                    systolic: _value1!.toInt(),
                    diastolic: _value2!.toInt(),
                  ),
          );
        case MeasurementTypeContract.oxygenSaturation:
          return measurement.copyWith(
            oxygenSaturation: _value1?.toInt(),
          );
        case MeasurementTypeContract.steps:
          return measurement.copyWith();
        case MeasurementTypeContract.globalPosition:
          return measurement.copyWith();
        case MeasurementTypeContract.heartRate:
          return measurement.copyWith(
            heartRate: _value1?.toInt(),
          );
        case MeasurementTypeContract.ews:
          return measurement.copyWith(
            heartRate: _value1?.toInt(),
          );
        case MeasurementTypeContract.respiratoryRate:
          return measurement.copyWith(
            respiratoryRate: _value1?.toInt(),
          );
        case MeasurementTypeContract.shortnessOfBreath:
          return measurement.copyWith(
            shortnessOfBreath: _value1 == null
                ? null
                : ShortnessOfBreathContract.values[_value1!.toInt()],
          );
        case MeasurementTypeContract.overallHealth:
          return measurement.copyWith(
            overallHealth: _value1 == null
                ? null
                : OverallHealthContract.values[_value1!.toInt()],
          );
        case MeasurementTypeContract.battery:
          return measurement.copyWith(
              batteryPercentage: _value1?.toInt(),
          );
      }
    }

    return null;
  }

  void reset() {
    formKey.currentState?.reset();
    for (final globalKey in fieldGlobalKeys) {
      globalKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final measurementConfig = ConfigurationConstants.supportedMeasurements[measurementType];

    if (measurementConfig == null) return const SizedBox.shrink();

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.common_measurement_units_names(
                        measurementConfig.unitNames[0].name,
                      ),
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Gaps.gap8,
                    if (measurementConfig.type == MeasurementConfigType.select)
                      ScaleSelectFormField(
                        textFormKey: fieldGlobalKeys[0],
                        onChanged: (double? value) => {_value1 = value},
                        measurementType: measurementType,
                      )
                    else
                      ScaleTextFormField(
                        key: ObjectKey(measurementConfig.type),
                        textFormKey: fieldGlobalKeys[0],
                        hintText: measurementConfig.hintText?[0] ?? "",
                        keyboardType: measurementConfig.textInputType,
                        suffixIcon: measurementConfig.units?.isNotEmpty == true
                            ? Text(
                                measurementConfig.units![0],
                                style: ScaleTextStyles.text.apply(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            : null,
                        validator: (value) {
                          _value1 = null;
                          if (value == null || value.isEmpty) {
                            return localization.common_wrong_value;
                          }

                          final parsedValue = value.toDouble();

                          if (measurementConfig.min != null &&
                                  measurementConfig.min! > parsedValue ||
                              measurementConfig.max != null &&
                                  measurementConfig.max! < parsedValue) {
                            return localization.common_wrong_value;
                          } else {
                            _value1 = parsedValue;
                            return null;
                          }
                        },
                        inputFormatters: measurementConfig.inputFormatters,
                      ),
                  ],
                ),
              ),
              if (measurementConfig.type == MeasurementConfigType.composed) ...[
                Gaps.gap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.common_measurement_units_names(
                          measurementConfig.unitNames[1].name,
                        ),
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      Gaps.gap8,
                      ScaleTextFormField(
                        textFormKey: fieldGlobalKeys[1],
                        hintText: measurementConfig.hintText?[1] ?? '',
                        keyboardType: measurementConfig.textInputType,
                        suffixIcon: measurementConfig.units?.isNotEmpty == true
                            ? Text(
                                measurementConfig.units![1],
                                style: ScaleTextStyles.text.apply(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            : null,
                        validator: (value) {
                          _value2 = null;
                          if (value == null || value.isEmpty) {
                            return localization.common_wrong_value;
                          }

                          final parsedValue = value.toDouble();

                          if (measurementConfig.min != null &&
                                  measurementConfig.min! > parsedValue ||
                              measurementConfig.max != null &&
                                  measurementConfig.max! < parsedValue) {
                            return localization.common_wrong_value;
                          }
                          if (measurementType ==
                                  MeasurementTypeContract.bloodPressure &&
                              _value1 != null &&
                              _value1! < parsedValue) {
                            return localization.common_diastolic_gt_systolic;
                          }

                          _value2 = parsedValue;
                          return null;
                        },
                        inputFormatters: measurementConfig.inputFormatters,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
