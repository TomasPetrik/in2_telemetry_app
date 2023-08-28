import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/omron_flow_route.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blured_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/device_item.dart';
import 'package:scalesoft_app/utils/constants.dart';

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({
    super.key,
    required this.userId,
    required this.measurementType,
  });

  final String userId;
  final MeasurementTypeContract measurementType;

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
                      Dimensions.appBarHeight,
                ),
                ...Constants.supportedDevices
                    .map(
                      (supportedDevice) => InkWell(
                        onTap: () {
                          GoRouter.of(context).pushNamed(
                            OmronFlowRoute.name,
                            queryParams: {
                              'userId': userId,
                              'measurementType': measurementType.name,
                              'modelName': '${supportedDevice.modelName}',
                              'deviceManufacturer':
                                  '${supportedDevice.deviceManufacturer}',
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
                    .toList(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BluredScaleAppBar(
              title: localization.add_device_screen_title,
              showClose: true,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
