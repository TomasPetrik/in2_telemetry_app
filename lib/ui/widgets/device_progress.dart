import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/action_item.dart';
import 'package:scalesoft_app/ui/widgets/device_progress_list.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceProgress extends StatelessWidget {
  const DeviceProgress({
    super.key,
    required this.device,
    required this.activeIndex,
    required this.header,
    required this.reqPairing,
  });

  final DeviceCreateModel device;
  final int activeIndex;
  final Widget header;
  final bool reqPairing;

  @override
  Widget build(BuildContext context) {
    final topGap = MediaQuery.of(context).viewPadding.top;
    final fixedHeight = topGap + Dimensions.twoLinedBarHeight;
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SliverGap(fixedHeight),
        header,
        const SliverGap(Dimensions.padding42),
        SliverToBoxAdapter(
          child: Text(
            localization.common_procedure,
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
        if (device.prototype.aboutUrl != null) ...[
          ActionItem(
            label: localization.find_device_screen_device_reference,
            onTap: () async {
              if (!await launchUrl(
                Uri.parse(device.prototype.aboutUrl!),
                mode: LaunchMode.externalApplication,
              )) {
                throw Exception('Could not launch ${device.prototype.aboutUrl}');
              }
            },
          ),
          const SliverGap(Dimensions.padding20),
        ],
      ],
    );
  }
}
