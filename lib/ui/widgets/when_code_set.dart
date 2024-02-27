import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  final TimeOfDayContract defaultTime;
  final TimeOfDayContract? minTime;
  final TimeOfDayContract? maxTime;
  final WhenCodeContract? whenCode;
  final Function(TimeOfDayContract dailyTime) onNewTimeSet;

  @override
  State<WhenCodeSet> createState() => _WhenCodeSetState();
}

class _WhenCodeSetState extends State<WhenCodeSet> with BottomSheetMixin {
  late WhenCodeContract? whenCode;

  late TimeOfDayContract defaultTime;
  late TimeOfDayContract? minTime;
  late TimeOfDayContract? maxTime;
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
          whenCode != null
              ? '${localization.common_when_code(whenCode!.name)} ${localization.common_from.toLowerCase()}'
              : localization.common_to.toLowerCase(),
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}
