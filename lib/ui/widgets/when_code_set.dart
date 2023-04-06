import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/care_plan/timing_day_when.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class WhenCodeSet extends StatefulWidget {
  const WhenCodeSet({
    super.key,
    required this.defaultTime,
    this.minTime,
    this.maxTime,
    this.whenCode,
    required this.onNewTimeSet,
  });

  final DailyTime defaultTime;
  final DailyTime? minTime;
  final DailyTime? maxTime;
  final WhenCode? whenCode;
  final Function(DailyTime dailyTime) onNewTimeSet;

  @override
  State<WhenCodeSet> createState() => _WhenCodeSetState();
}

class _WhenCodeSetState extends State<WhenCodeSet> with BottomSheetMixin {
  late WhenCode? whenCode;

  late DailyTime defaultTime;
  late DailyTime? minTime;
  late DailyTime? maxTime;
  late TextEditingController timeTextController;

  @override
  void initState() {
    whenCode = widget.whenCode;

    defaultTime = widget.defaultTime;
    minTime = widget.minTime;
    maxTime = widget.maxTime;
    timeTextController = TextEditingController(text: defaultTime.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${whenCode != null ? translactions.common_when_code(whenCode!.name) : ''} ${translactions.common_from.toLowerCase()}',
          style: ScaleTextStyles.text.apply(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        Gaps.gap8,
        InkWell(
          onTap: () async {
            final newDateTime = await showRestrictedTimePicker(
              context: context,
              defaultTime: defaultTime,
              minTime: minTime,
              maxTime: maxTime,
            );

            if (newDateTime != null) {
              defaultTime = newDateTime;
              widget.onNewTimeSet.call(newDateTime);
              timeTextController.text = newDateTime.toString();
            }
          },
          child: Stack(
            children: [
              TextField(
                enabled: false,
                controller: timeTextController,
                style: ScaleTextStyles.text.apply(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Positioned(
                right: Dimensions.padding16,
                top: Dimensions.padding12,
                bottom: Dimensions.padding12,
                child: SvgPicture.asset(
                  'assets/icons/icon_right.svg',
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
