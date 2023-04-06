import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/utils/extensions/date_extensions.dart';

class DeviceItem extends StatelessWidget {
  const DeviceItem({
    super.key,
    required this.device,
    this.onRemove,
  });

  final Device device;
  final VoidCallback? onRemove;

  String getSubTitle(BuildContext context) {
    String subTitle = translactions.measurement_dialog_device_desc(
      device.deviceModel!.name,
    );

    if (device.addedAt != null) {
      subTitle +=
          '\n${translactions.common_addded_at_time(device.addedAt!.toDateFormatLong2())}';
    }

    return subTitle;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadii.radius8,
          child: SizedBox(
            height: 64,
            width: 64,
            child: Image.asset(device.imagePath!),
          ),
        ),
        Gaps.gap16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.modelName ?? '',
                style: ScaleTextStyles.text.apply(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Gaps.gap6,
              Text(
                getSubTitle(context),
                style: ScaleTextStyles.label.apply(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ),
        if (onRemove != null) ...[
          Gaps.gap16,
          InkWell(
            onTap: onRemove,
            child: SvgPicture.asset(
              'assets/icons/icon_trash.svg',
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ]
      ],
    );
  }
}
