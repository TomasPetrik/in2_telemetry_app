import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/action_item.dart';
import 'package:scalesoft_app/ui/widgets/device_progress_list.dart';

class DeviceProgress extends StatelessWidget {
  const DeviceProgress({
    super.key,
    required this.device,
    required this.activeIndex,
    required this.header,
    required this.reqPairing,
  });

  final Device device;
  final int activeIndex;
  final Widget header;
  final bool reqPairing;

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).viewPadding.top;
    final fixedHeight = topGap + Constants.twoLinedBarHeight;
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SliverGap(fixedHeight),
        header,
        const SliverGap(Dimensions.padding42),
        SliverToBoxAdapter(
          child: Text(
            context.locale.common_procedure,
            style: ScaleTextStyles.textAccent.apply(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
        DeviceProgressList(
          device: device,
          reqPairing: reqPairing,
          activeIndex: activeIndex,
        ),
        const SliverGap(Dimensions.padding60),
        ActionItem(
          label: context.locale.find_device_screen_device_reference,
          onTap: () {},
        ),
      ],
    );
  }
}
