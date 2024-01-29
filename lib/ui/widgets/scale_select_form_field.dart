import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/measurement/overall_health_value.dart';
import 'package:scalesoft_app/api/model/measurement/shortness_of_breath_value.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class ScaleSelectFormField extends StatelessWidget {
  final Key textFormKey;
  final ValueChanged<double?> onChanged;
  final MeasurementTypeContract measurementType;

  ScaleSelectFormField({
    super.key,
    required this.textFormKey,
    required this.onChanged,
    required this.measurementType,
  }) {
    // Propagate prefilled default value
    onChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    return switch (measurementType) {
      MeasurementTypeContract.shortnessOfBreath =>
        DropdownButtonFormField<ShortnessOfBreathValue>(
          icon: SvgPicture.asset('assets/icons/icon_right.svg'),
          elevation: 0,
          style: ScaleTextStyles.text.apply(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          items: ShortnessOfBreathValue.values
              .map<DropdownMenuItem<ShortnessOfBreathValue>>(
                (ShortnessOfBreathValue value) => DropdownMenuItem(
                  value: value,
                  child: Text(localization.shortness_of_breath_values(value)),
                ),
              )
              .toList(),
          onChanged: (ShortnessOfBreathValue? value) {
            onChanged(value?.index.toDouble());
          },
          value: ShortnessOfBreathValue.none,
        ),
      MeasurementTypeContract.overallHealth =>
        DropdownButtonFormField<OverallHealthValue>(
          icon: SvgPicture.asset('assets/icons/icon_right.svg'),
          elevation: 0,
          style: ScaleTextStyles.text.apply(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          items: OverallHealthValue.values
              .map<DropdownMenuItem<OverallHealthValue>>(
                (OverallHealthValue value) => DropdownMenuItem(
                  value: value,
                  child: Text(localization.overall_health_values(value)),
                ),
              )
              .toList(),
          onChanged: (OverallHealthValue? value) {
            onChanged(value?.index.toDouble());
          },
          value: OverallHealthValue.good,
        ),
      _ => throw UnsupportedError("Selected measurement type is not supported"),
    };
  }
}
