import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/permissions/permission_grant_widget.dart';
import 'package:scalesoft_app/ui/widgets/scale_switch.dart';

class PermissionState {
  Permission permission;
  bool isGranted;
  bool isMandatory;

  PermissionState({
    required this.permission,
    this.isGranted = false,
    this.isMandatory = false,
  });
}

class SynchronizationSetupWidget extends StatefulWidget {
  final int androidSdk;

  const SynchronizationSetupWidget({super.key, required this.androidSdk});

  @override
  State<SynchronizationSetupWidget> createState() => _SynchronizationSetupWidgetState();
}

class _SynchronizationSetupWidgetState extends State<SynchronizationSetupWidget> {
  late List<PermissionState> permissionStatusList;
  bool toggleValue = false;

  List<PermissionState> createPermissionStatusList() {
    return [
      if (widget.androidSdk < 31) PermissionState(permission: Permission.notification, isMandatory: true),
      if (widget.androidSdk >= 31)
        PermissionState(
          permission: Permission.bluetoothConnect,
          isMandatory: true,
        ),
      PermissionState(
        permission: Permission.ignoreBatteryOptimizations,
        isMandatory: false,
      ),
    ];
  }

  bool get areMandatoryPermissionsGranted {
    return permissionStatusList.every((element) => !element.isMandatory || element.isGranted);
  }

  @override
  void initState() {
    super.initState();
    permissionStatusList = createPermissionStatusList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // Workaround: PopScope does not work correctly with GoRouter. Pop manually.
        // https://github.com/flutter/flutter/issues/138737
        GoRouter.of(context).pop();
      },
      child: Column(
        children: [
          Center(
            child: Text(localization.watch_setup_explanation),
          ),
          Gaps.gap16,
          Column(
            children: permissionStatusList
                .map(
                  (entry) => PermissionGrantWidget(
                    permission: entry.permission,
                    onStatusChanged: (status) {
                      setState(() {
                        entry.isGranted = status == PermissionStatus.granted;
                      });
                    },
                  ),
                )
                .toList(),
          ),
          Gaps.gap16,
          InkWell(
            onTap: () {
              if (areMandatoryPermissionsGranted) {
                setState(() {
                  toggleValue = !toggleValue;
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localization.watch_synchronization_toggle_label),
                ScaleSwitch(
                  value: toggleValue,
                  onChanged: areMandatoryPermissionsGranted
                      ? (value) => setState(() => toggleValue = value)
                      : null, // Disable the switch if permissions not granted
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
