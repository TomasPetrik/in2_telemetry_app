import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/cubit/background_measurement/background_measurement_cubit.dart';
import 'package:scalesoft_app/cubit/background_measurement/background_measurement_state.dart';
import 'package:scalesoft_app/cubit/loader/loader_cubit.dart';
import 'package:scalesoft_app/managers/background_measurement_manager.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/permissions/permission_grant_widget.dart';

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
  final LoaderCubit loaderCubit;

  const SynchronizationSetupWidget({super.key, required this.androidSdk, required this.loaderCubit});

  @override
  State<SynchronizationSetupWidget> createState() => _SynchronizationSetupWidgetState();
}

class _SynchronizationSetupWidgetState extends State<SynchronizationSetupWidget> {
  late List<PermissionState> permissionStatusList;
  late LoaderCubit loaderCubit = widget.loaderCubit;

  final BackgroundMeasurementCubit backgroundMeasurementCubit = getIt<BackgroundMeasurementCubit>();
  final BackgroundMeasurementManager backgroundMeasurementManager = getIt<BackgroundMeasurementManager>();

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
    loaderCubit = widget.loaderCubit;
  }

  Future<void> toggleSynchronization(bool value) async {
    loaderCubit.loading();

    value
        ? await backgroundMeasurementManager.activateBackgroundSynchronization()
        : await backgroundMeasurementManager.deactivateBackgroundSynchronization();

    await backgroundMeasurementManager.updateBackgroundSynchronizationState();

    loaderCubit.loaded();
  }

  void updateBackgroundSynchronizationState() async {
    loaderCubit.loading();
    await backgroundMeasurementManager.updateBackgroundSynchronizationState();
    loaderCubit.loaded();
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
          BlocBuilder<BackgroundMeasurementCubit, BackgroundMeasurementState>(
            bloc: backgroundMeasurementCubit,
            builder: ((context, state) {
              final toggleState = state != BackgroundMeasurementState.disabled;

              // TODO: Show a yellow warning icon that provides an explanation snackbar on tap.
              final showWarning = state == BackgroundMeasurementState.partial;

              final widget = InkWell(
                onTap: () {
                  if (areMandatoryPermissionsGranted) {
                    toggleSynchronization(!toggleState);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(localization.watch_synchronization_toggle_label),
                    CupertinoSwitch(
                      trackColor: Theme.of(context).colorScheme.tertiary,
                      activeColor: Theme.of(context).colorScheme.primary,
                      thumbColor: Theme.of(context).colorScheme.background,
                      onChanged: areMandatoryPermissionsGranted ? toggleSynchronization : null,
                      value: toggleState,
                    ),
                  ],
                ),
              );

              return widget;
            }),
          ),
        ],
      ),
    );
  }
}
