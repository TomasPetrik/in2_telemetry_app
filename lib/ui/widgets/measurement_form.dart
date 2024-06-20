import 'package:flutter/material.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/enums/overall_health_state.dart';
import 'package:scalesoft_app/data/entities/enums/shortness_of_breath_level.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement/blood_pressure_value.dart';
import 'package:scalesoft_app/model/measurement_config.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';
import 'package:scalesoft_app/model/user_model.dart';
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
    required this.user,
  });

  final MeasurementType measurementType;
  final UserModel user;

  double? _value1;
  double? _value2;

  MeasurementCreateModel? getMeasurement() {
    if (formKey.currentState?.validate() == true) {
      final measurement = MeasurementCreateModel(
        user.id,
        DateTime.now(),
        measurementType,
      );
      switch (measurementType) {
        case MeasurementType.temperature:
          measurement.temperature = _value1;
          return measurement;
        case MeasurementType.bloodPressure:
          measurement.bloodPressure = _value1 == null || _value2 == null
              ? null
              : BloodPressureValue(
                  systolic: _value1!.toInt(),
                  diastolic: _value2!.toInt(),
                );
          return measurement;
        case MeasurementType.oxygenSaturation:
          measurement.oxygenSaturation = _value1?.toInt();
          return measurement;
        case MeasurementType.steps:
          return measurement;
        case MeasurementType.globalPosition:
          return measurement;
        case MeasurementType.heartRate:
          measurement.heartRate = _value1?.toInt();
          return measurement;
        case MeasurementType.ews:
          return measurement;
        case MeasurementType.respiratoryRate:
          measurement.respiratoryRate = _value1?.toInt();
          return measurement;
        case MeasurementType.shortnessOfBreath:
          measurement.shortnessOfBreath = _value1 == null ? null : ShortnessOfBreathLevel.values[_value1!.toInt()];
          return measurement;
        case MeasurementType.overallHealth:
          measurement.overallHealth = _value1 == null ? null : OverallHealthState.values[_value1!.toInt()];
          return measurement;
        case MeasurementType.battery:
          measurement.batteryPercentage = _value1?.toInt();
          return measurement;
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
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            : null,
                        validator: (value) {
                          _value1 = null;
                          if (value == null || value.isEmpty) {
                            return localization.common_wrong_value;
                          }

                          final parsedValue = value.toDouble();

                          if (measurementConfig.min != null && measurementConfig.min! > parsedValue ||
                              measurementConfig.max != null && measurementConfig.max! < parsedValue) {
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
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            : null,
                        validator: (value) {
                          _value2 = null;
                          if (value == null || value.isEmpty) {
                            return localization.common_wrong_value;
                          }

                          final parsedValue = value.toDouble();

                          if (measurementConfig.min != null && measurementConfig.min! > parsedValue ||
                              measurementConfig.max != null && measurementConfig.max! < parsedValue) {
                            return localization.common_wrong_value;
                          }
                          if (measurementType == MeasurementType.bloodPressure &&
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
