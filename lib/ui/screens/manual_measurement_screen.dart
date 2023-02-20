import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/measurement_form.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class ManualMeasurementScreen extends StatefulWidget {
  const ManualMeasurementScreen({
    super.key,
    required this.userId,
    this.measurementType,
  });

  final MeasurementType? measurementType;
  final String userId;

  @override
  State<ManualMeasurementScreen> createState() =>
      _ManualMeasurementScreenState();
}

class _ManualMeasurementScreenState extends State<ManualMeasurementScreen>
    with BottomSheetMixin {
  late MeasurementType dropdownValue;

  late TextEditingController timeEditingController;
  late DateTime measurementDateTime;

  @override
  void initState() {
    dropdownValue = widget.measurementType ?? MeasurementType.values.first;

    final currentDateTime = DateTime.now();
    timeEditingController = TextEditingController(
      text: currentDateTime.toTimeOfDay().toString(),
    );
    measurementDateTime = currentDateTime;
    super.initState();
  }

  void _goToMainAndSync() {
    GoRouter.of(context).pop();
    getIt<SyncBloc>().add(const SyncEvent.syncResults());
  }

  @override
  Widget build(BuildContext context) {
    final measurementForm = MeasurementForm(
      key: UniqueKey(),
      userId: widget.userId,
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
                    Text(
                      context.locale.manual_measurement_screen_measurement_time,
                    ),
                    Gaps.gap8,
                    InkWell(
                      onTap: () async {
                        final newDateTime = await showRestrictedTimePicker(
                          context: context,
                          currentDateTime: DateTime.now(),
                        );

                        if (newDateTime != null) {
                          measurementDateTime = newDateTime;
                          timeEditingController.text =
                              newDateTime.toTimeOfDay().toString();
                        }
                      },
                      child: Stack(
                        children: [
                          TextField(
                            enabled: false,
                            controller: timeEditingController,
                            style: ScaleTextStyles.text.apply(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          Positioned(
                            right: Dimensions.padding16,
                            top: Dimensions.padding12,
                            bottom: Dimensions.padding12,
                            child: SvgPicture.asset(
                              'assets/icons/icon_clock.svg',
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        ],
                      ),
                    ),
                    Gaps.gap24,
                    HighlightedElevatedButton(
                      label: context.locale.common_save,
                      buttonType: ButtonType.primary,
                      onPressed: () async {
                        final measurement = measurementForm.getMeasurement();
                        if (measurement != null) {
                          final measurementWithTime = measurement.copyWith(
                            measurementDateTime: measurementDateTime.toUtc(),
                          );
                          await getIt<PendingResultsDbProvider>()
                              .save(measurementWithTime);
                          _goToMainAndSync();
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
