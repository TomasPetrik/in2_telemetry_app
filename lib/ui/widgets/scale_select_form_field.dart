import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scalesoft_app/api/contracts/measurement/overall_health_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/shortness_of_breath_contract.dart';
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
        DropdownButtonFormField<ShortnessOfBreathContract>(
          icon: SvgPicture.asset('assets/icons/icon_right.svg'),
          elevation: 0,
          style: ScaleTextStyles.text.apply(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          items: ShortnessOfBreathContract.values
              .map<DropdownMenuItem<ShortnessOfBreathContract>>(
                (ShortnessOfBreathContract value) => DropdownMenuItem(
                  value: value,
                  child: Text(localization.shortness_of_breath_values(value)),
                ),
              )
              .toList(),
          onChanged: (ShortnessOfBreathContract? value) {
            onChanged(value?.index.toDouble());
          },
          value: ShortnessOfBreathContract.none,
        ),
      MeasurementTypeContract.overallHealth =>
        DropdownButtonFormField<OverallHealthContract>(
          icon: SvgPicture.asset('assets/icons/icon_right.svg'),
          elevation: 0,
          style: ScaleTextStyles.text.apply(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          items: OverallHealthContract.values
              .map<DropdownMenuItem<OverallHealthContract>>(
                (OverallHealthContract value) => DropdownMenuItem(
                  value: value,
                  child: Text(localization.overall_health_values(value)),
                ),
              )
              .toList(),
          onChanged: (OverallHealthContract? value) {
            onChanged(value?.index.toDouble());
          },
          value: OverallHealthContract.good,
        ),
      _ => throw UnsupportedError("Selected measurement type is not supported"),
    };
  }
}
