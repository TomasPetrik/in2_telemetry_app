import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/permissions/synchronization_setup_widget.dart';

class SetupWatchScreen extends StatefulWidget {
  const SetupWatchScreen({super.key});

  @override
  State<SetupWatchScreen> createState() => _SetupWatchScreenState();
}

class _SetupWatchScreenState extends State<SetupWatchScreen> {
  late DeviceInfoPlugin _deviceInfoPlugin;

  @override
  void initState() {
    super.initState();
    _deviceInfoPlugin = DeviceInfoPlugin();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              body: Padding(
                padding: Paddings.horizontal16,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Gap(
                        MediaQuery.of(context).viewPadding.top + Dimensions.appBarHeight,
                      ),
                      Gaps.gap16,
                      FutureBuilder<AndroidDeviceInfo>(
                        future: _deviceInfoPlugin.androidInfo,
                        builder: (BuildContext context, AsyncSnapshot<AndroidDeviceInfo> snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final int androidSdk = snapshot.data!.version.sdkInt;
                          return SynchronizationSetupWidget(androidSdk: androidSdk);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredScaleAppBar(
              title: localization.watch_setup_screen_title,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
