import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/measurement_form.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';

class ManualMeasurementScreen extends StatefulWidget {
  const ManualMeasurementScreen({
    super.key,
    this.measurementType,
  });

  final MeasurementType? measurementType;

  @override
  State<ManualMeasurementScreen> createState() =>
      _ManualMeasurementScreenState();
}

class _ManualMeasurementScreenState extends State<ManualMeasurementScreen> {
  late MeasurementType dropdownValue;

  @override
  void initState() {
    dropdownValue = widget.measurementType ?? MeasurementType.values.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final measurementForm = MeasurementForm(
      key: UniqueKey(),
      measurementType: dropdownValue,
    );

    return Material(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        onVerticalDragDown: (_) =>
            FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              left: 16,
              right: 16,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Gap(
                      MediaQuery.of(context).viewPadding.top +
                          Constants.appBarHeight,
                    ),
                    Gaps.gap16,
                    DropdownButtonFormField<MeasurementType>(
                      value: dropdownValue,
                      icon: SvgPicture.asset('assets/icons/icon_right.svg'),
                      elevation: 0,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onChanged: (MeasurementType? value) {
                        measurementForm.reset;
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      items: MeasurementType.values
                          .map<DropdownMenuItem<MeasurementType>>(
                              (MeasurementType measurementType) {
                        return DropdownMenuItem<MeasurementType>(
                          value: measurementType,
                          child: Text(
                            context.locale
                                .common_measurement_types(measurementType.name),
                          ),
                        );
                      }).toList(),
                    ),
                    Gaps.gap24,
                    measurementForm,
                    Gaps.gap24,
                    HighlightedElevatedButton(
                      label: context.locale.common_save,
                      buttonType: ButtonType.primary,
                      onPressed: () {
                        final measurement = measurementForm.getMeasurement();
                        if (measurement != null) {
                          //save and sync
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: ScaleAppBar(
                    title: context.locale.manual_measurement_screen_title,
                    showClose: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
