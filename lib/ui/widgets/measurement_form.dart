import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_int_value.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/scale_text_form_field.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

final formKey = GlobalKey<FormState>();
final List<GlobalKey<FormState>> fieldGlobalKeys = [
  GlobalKey<FormState>(),
  GlobalKey<FormState>()
];

class MeasurementForm extends StatelessWidget with BottomSheetMixin {
  MeasurementForm({
    super.key,
    required this.measurementType,
    required this.userId,
  });

  final MeasurementType measurementType;
  final String userId;

  double? _value1;
  double? _value2;
  DateTime? _measurementDateTime;

  Measurement? getMeasurement() {
    if (formKey.currentState?.validate() == true) {
      Measurement? measurement = Measurement(
        measurementDateTime: _measurementDateTime,
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

    final currentDateTime = DateTime.now();
    TextEditingController timeEditingController = TextEditingController(
      text: currentDateTime.toTimeOfDay().toString(),
    );
    _measurementDateTime = currentDateTime.toUtc();

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      context.locale.common_measurement_units_names(
                        measurementConfig.unitNames[0].name,
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
                          return context.locale.common_wrong_value;
                        } else {
                          _value1 = double.parse(value);
                          return null;
                        }
                      },
                      inputFormatters: const [],
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
                        context.locale.common_measurement_units_names(
                          measurementConfig.unitNames[1].name,
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
                            return context.locale.common_wrong_value;
                          } else {
                            _value2 = double.parse(value);
                            return null;
                          }
                        },
                        inputFormatters: const [],
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
          Gaps.gap24,
          Text(
            context.locale.manual_measurement_screen_measurement_time,
          ),
          Gaps.gap8,
          Stack(
            children: [
              TextField(
                enabled: false,
                controller: timeEditingController,
                style: ScaleTextStyles.text
                    .apply(color: Theme.of(context).colorScheme.tertiary),
              ),
              Positioned(
                right: Dimensions.padding16,
                top: Dimensions.padding12,
                bottom: Dimensions.padding12,
                child: InkWell(
                  onTap: () async {
                    final newDateTime = await showRestrictedTimePicker(
                      context: context,
                      currentDateTime: DateTime.now(),
                    );

                    if (newDateTime != null) {
                      _measurementDateTime = newDateTime.toUtc();
                      timeEditingController.text =
                          newDateTime.toTimeOfDay().toString();
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/icons/icon_clock.svg',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
