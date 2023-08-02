import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/dashboard_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/measurement_form.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class ManualMeasurementScreen extends StatefulWidget {
  const ManualMeasurementScreen({
    super.key,
    required this.userId,
    required this.measurementType,
    required this.enabledMeasurementTypes,
  });

  final MeasurementType measurementType;
  final String userId;
  final List<MeasurementType> enabledMeasurementTypes;

  @override
  State<ManualMeasurementScreen> createState() =>
      _ManualMeasurementScreenState();
}

class _ManualMeasurementScreenState extends State<ManualMeasurementScreen>
    with BottomSheetMixin {
  late MeasurementType dropdownValue;

  late TextEditingController timeEditingController;
  late DailyTime measurementTime;
  late List<MeasurementType> enabledMeasurementTypes;

  @override
  void initState() {
    dropdownValue = widget.measurementType;

    final currentTime = DateTime.now().toTimeOfDay();
    timeEditingController = TextEditingController(
      text: currentTime.toString(),
    );
    measurementTime = currentTime;
    enabledMeasurementTypes = widget.enabledMeasurementTypes;
    super.initState();
  }

  void _goToMainAndSync() {
    getIt<SyncBloc>().add(const SyncEvent.syncResults());
    GoRouter.of(context).goNamed(DashboardRoute.name);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(
                      MediaQuery.of(context).viewPadding.top +
                          Dimensions.appBarHeight,
                    ),
                    Gaps.gap16,
                    Text(
                      localization.manual_measurement_screen_type,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
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
                      items: enabledMeasurementTypes
                          .map<DropdownMenuItem<MeasurementType>>(
                              (MeasurementType measurementType) {
                        return DropdownMenuItem<MeasurementType>(
                          value: measurementType,
                          child: Text(
                            localization
                                .common_measurement_types(measurementType.name),
                          ),
                        );
                      }).toList(),
                    ),
                    Gaps.gap24,
                    measurementForm,
                    Gaps.gap24,
                    Text(
                      localization.manual_measurement_screen_measurement_time,
                      style: ScaleTextStyles.text.apply(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Gaps.gap8,
                    InkWell(
                      onTap: () async {
                        final newDateTime = await showRestrictedTimePicker(
                          context: context,
                        );

                        if (newDateTime != null) {
                          measurementTime = newDateTime;
                          timeEditingController.text = newDateTime.toString();
                        }
                      },
                      child: Stack(
                        children: [
                          TextField(
                            enabled: false,
                            controller: timeEditingController,
                            style: ScaleTextStyles.text.apply(
                              color: Theme.of(context).colorScheme.onPrimary,
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
                      label: localization.common_save,
                      buttonType: ButtonType.primary,
                      onPressed: () async {
                        final measurement = measurementForm.getMeasurement();
                        if (measurement != null) {
                          final measurementWithTime = measurement.copyWith(
                            measurementDateTime:
                                measurementTime.todayDateTime().toUtc(),
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
                    title: localization.manual_measurement_screen_title,
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
