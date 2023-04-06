import 'package:flutter/material.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_int_value.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/model/measurement_config.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/scale_text_form_field.dart';
import 'package:scalesoft_app/utils/constants.dart';

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

  final MeasurementType measurementType;
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
        case MeasurementType.temperature:
          return measurement.copyWith(
            temperature: _value1,
          );
        case MeasurementType.bloodPressure:
          return measurement.copyWith(
            bloodPressure: BloodPressureValue(
              systolic: _value1?.toInt(),
              diastolic: _value2?.toInt(),
            ),
          );

        case MeasurementType.oxygenSaturation:
          return measurement.copyWith(
            oxygenSaturation: _value1?.toInt(),
          );
        case MeasurementType.steps:
          return measurement.copyWith();
        case MeasurementType.globalPosition:
          return measurement.copyWith();
        case MeasurementType.heartRate:
          return measurement.copyWith(
            heartRate: _value1?.toInt(),
          );
        case MeasurementType.ews:
          return measurement.copyWith(
            heartRate: _value1?.toInt(),
          );
        case MeasurementType.respiratoryRate:
          return measurement.copyWith(
            respiratoryRate: _value1?.toInt(),
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
    final measurementConfig = Constants.supportedMeasurements[measurementType];

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
                      translactions.common_measurement_units_names(
                        measurementConfig.unitNames[0].name,
                      ),
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Gaps.gap8,
                    ScaleTextFormField(
                      key: ObjectKey(measurementConfig.type),
                      textFormKey: fieldGlobalKeys[0],
                      hintText: measurementConfig.hintText[0],
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
                        if (value == null ||
                            value.isEmpty == true ||
                            measurementConfig.min > double.parse(value) ||
                            measurementConfig.max < double.parse(value)) {
                          return translactions.common_wrong_value;
                        } else {
                          _value1 = double.parse(value);
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
                        translactions.common_measurement_units_names(
                          measurementConfig.unitNames[1].name,
                        ),
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      Gaps.gap8,
                      ScaleTextFormField(
                        textFormKey: fieldGlobalKeys[1],
                        hintText: measurementConfig.hintText[1],
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
                          if (value == null ||
                              value.isEmpty == true ||
                              measurementConfig.min > double.parse(value) ||
                              measurementConfig.max < double.parse(value)) {
                            return translactions.common_wrong_value;
                          } else {
                            _value2 = double.parse(value);
                            return null;
                          }
                        },
                        inputFormatters: measurementConfig.inputFormatters,
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
