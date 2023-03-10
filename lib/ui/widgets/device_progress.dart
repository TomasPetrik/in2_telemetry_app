import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/screens/icon_label_row.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/action_item.dart';

class DeviceProgress extends StatelessWidget {
  const DeviceProgress({
    super.key,
    required this.device,
    required this.activeIndex,
    required this.header,
    required this.reqModelPairing,
  });

  final Device device;
  final int activeIndex;
  final Widget header;
  final DeviceModel? reqModelPairing;

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
        const SliverGap(Dimensions.padding36),
        ConnectionLevel(
          label: reqModelPairing != null
              ? context.locale.find_device_screen_step1_p(
                  device.modelName ?? '',
                )
              : context.locale.find_device_screen_step1(
                  device.modelName ?? '',
                ),
          iconPath: 'assets/icons/icon_power_off.svg',
          isActive: activeIndex >= 1,
        ),
        const SliverGap(Dimensions.padding34),
        ConnectionLevel(
          label: reqModelPairing != null
              ? context.locale.find_device_screen_step2_p
              : context.locale.find_device_screen_step2,
          iconPath: 'assets/icons/icon_bluetooth_on.svg',
          isActive: activeIndex >= 2,
        ),
        const SliverGap(Dimensions.padding34),
        ConnectionLevel(
          label: reqModelPairing != null
              ? context.locale.find_device_screen_step3_p
              : context.locale.find_device_screen_step3,
          iconPath: 'assets/icons/icon_arrow_spin.svg',
          isActive: activeIndex >= 3,
        ),
        if (reqModelPairing == null) ...[
          const SliverGap(Dimensions.padding34),
          ConnectionLevel(
            label: context.locale.find_device_screen_step4,
            iconPath: 'assets/icons/icon_wave_pulse.svg',
            isActive: activeIndex >= 4,
          ),
        ],
        const SliverGap(Dimensions.padding60),
        ActionItem(
          label: context.locale.find_device_screen_device_reference,
          onTap: () {},
        ),
      ],
    );
  }
}
