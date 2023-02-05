import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/manual_measurement.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/scale_text_form_field.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

final formKey = GlobalKey<FormState>();
final timeFieldKey = GlobalKey<FormFieldState>();
final List<GlobalKey<FormState>> fieldGlobalKeys = [
  GlobalKey<FormState>(),
  GlobalKey<FormState>()
];

class MeasurementForm extends StatelessWidget {
  const MeasurementForm({
    super.key,
    required this.measurementType,
  });

  final MeasurementType measurementType;

  ManualMeasurement? getMeasurement() {
    if (formKey.currentState?.validate() == true) {}

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

    if (measurementConfig == null) return const SizedBox();

    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.always,
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
          ScaleTextFormField(
            textFormKey: timeFieldKey,
            initialValue: DateTime.now().toTimeOfDay().toString(),
            hintText: '00:00',
            validator: (value) {
              if (value?.isEmpty == true ||
                  !RegExp(r'^(?:[01]?\d|2[0-3])(?::(?:[0-5]\d?)?)?$')
                      .hasMatch(value!)) {
                return context.locale.common_wrong_value;
              } else {
                return null;
              }
            },
            keyboardType: TextInputType.datetime,
            suffixIcon: SvgPicture.asset(
              'assets/icons/icon_clock.svg',
              color: Theme.of(context).colorScheme.primary,
            ),
            inputFormatters: [
              TimeTextFormatter(),
            ],
          ),
        ],
      ),
    );
  }
}
