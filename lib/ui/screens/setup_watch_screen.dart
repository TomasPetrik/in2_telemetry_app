import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/cubit/loader/loader_cubit.dart';
import 'package:scalesoft_app/cubit/loader/loader_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';
import 'package:scalesoft_app/ui/widgets/permissions/synchronization_setup_widget.dart';

class SetupWatchScreen extends StatelessWidget {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  final loaderCubit = getIt<LoaderCubit>()..loading();

  SetupWatchScreen({super.key});

  Future<AndroidDeviceInfo> getDeviceInfo() async {
    loaderCubit.loading();
    final androidInfo = await _deviceInfoPlugin.androidInfo;
    loaderCubit.loaded();
    return androidInfo;
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
                        future: getDeviceInfo(),
                        builder: (BuildContext context, AsyncSnapshot<AndroidDeviceInfo> snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }
                          final int androidSdk = snapshot.data!.version.sdkInt;
                          return SynchronizationSetupWidget(
                            androidSdk: androidSdk,
                            loaderCubit: loaderCubit,
                          );
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
          BlocBuilder<LoaderCubit, LoaderState>(
            bloc: loaderCubit,
            builder: ((context, state) {
              final widget = state.when(
                loaded: SizedBox.shrink,
                loading: () {
                  return Stack(
                    children: [
                      SizedBox.expand(
                        child: ColoredBox(color: Colors.black.withOpacity(0.4)),
                      ),
                      const Align(alignment: Alignment.center, child: LoadingIndicator()),
                    ],
                  );
                },
              );

              return widget;
            }),
          ),
        ],
      ),
    );
  }
}
