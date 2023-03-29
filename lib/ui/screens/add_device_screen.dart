import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/ui/routers/routes/omron_flow_route.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/device_item.dart';

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({
    super.key,
    required this.userId,
    required this.measurementType,
  });

  final String userId;
  final MeasurementType measurementType;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            padding: Paddings.horizontal16,
            child: Column(
              children: [
                Gap(
                  MediaQuery.of(context).viewPadding.top +
                      Constants.appBarHeight,
                ),
                ...Constants.supportedDevices
                    .map(
                      (supportedDevice) => InkWell(
                        onTap: () {
                          GoRouter.of(context).pushNamed(
                            OmronFlowRoute.name,
                            params: {
                              'userId': userId,
                              'measurementType': measurementType.name,
                              'deviceId': '${supportedDevice.localId}'
                            },
                          );
                        },
                        child: Container(
                          padding: Paddings.top24,
                          child: DeviceItem(
                            device: supportedDevice,
                          ),
                        ),
                      ),
                    )
                    .toList()
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BluredScaleAppBar(
              title: context.locale.add_device_screen_title,
              showClose: true,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
