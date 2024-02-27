import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_contract.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class DeviceItem extends StatelessWidget {
  const DeviceItem({
    super.key,
    required this.device,
    this.onRemove,
  });

  final SourceDeviceContract device;
  final VoidCallback? onRemove;

  String getSubTitle(BuildContext context) {
    String? subTitle = '';
    /*
     subTitle += localization.measurement_dialog_device_desc(
      device.deviceModelType!.name,
    );
    */

    if (device.deviceIdentifier != null) {
      subTitle += device.deviceIdentifier!;
    }

    if (device.assignedIdentifier != null) {
      subTitle +=
          '\n(${device.assignedIdentifier!})'; //for assigned devices show assigned identifier
    } else if (device.addedAt != null) {
      //for own devices show when device was added
      subTitle +=
          '\n${localization.common_addded_at_time(device.addedAt!.dateFormatLong)}';
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
                device.visibleName ?? '',
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
        ],
      ],
    );
  }
}
