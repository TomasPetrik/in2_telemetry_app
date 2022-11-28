import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/cubit/omron/omron_connection_cubit.dart';
import 'package:scalesoft_app/cubit/omron/omron_connection_state.dart';
import 'package:scalesoft_app/model/measurement_result.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/measurement_result_screen.dart';
import 'package:scalesoft_app/ui/screens/mixins/popup_dialog_mixin.dart';
import 'package:scalesoft_app/ui/screens/select_device_screen.dart';

const Map<String, String> characteristicsMap = {
  "00002a49-0000-1000-8000-00805f9b34fb": 'Blood pressure feature char',
  "00002a35-0000-1000-8000-00805f9b34fb": 'Blood pressure measurement char'
};

class FindOmronDeviceScreen extends StatelessWidget with PopupDialogMixin {
  const FindOmronDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OmronConnectionCubit omronConnectionCubit = getIt<OmronConnectionCubit>();

    /*
    omronConnectionBloc.state.whenOrNull(
      connected: (device, deviceInfo) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return DeviceScreen(device: device);
            },
          ),
        );
        showPopup(context, message: deviceInfo.toString());
      },
    );
    */
    return WillPopScope(
      onWillPop: () async {
        await omronConnectionCubit.stopSearch();
        return true;
      },
      child: Scaffold(
        body: BlocConsumer<OmronConnectionCubit, OmronConnectionState>(
          bloc: omronConnectionCubit..checkDeviceAvailability(),
          listener: (context, state) {
            state.whenOrNull(
              verified: (device, deviceInfo) {
                /*
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return DevicesScreen(device: device);
                    },
                  ),
                );
                */
                /*
                showPopup(
                  context,
                  message: deviceInfo.toString(),
                  hideAfter: const Duration(seconds: 1),
                );

                */
              },
              synced: (measurementResult) {
                switch (measurementResult.resultState) {
                  case ResultState.success:
                    Navigator.pushReplacementNamed(
                      context,
                      MeasurementResultScreen.routeName,
                      arguments: measurementResult.measurementInfo,
                    );
                    break;
                  case ResultState.noData:
                    showPopup(
                      context,
                      message: 'No data available',
                      afterHideAction: () {
                        Navigator.pushReplacementNamed(
                          context,
                          SelectDeviceScreen.routeName,
                          arguments: measurementResult.measurementInfo,
                        );
                      },
                    );
                    break;
                  case ResultState.connectionError:
                    showPopup(
                      context,
                      message: 'Connection Error',
                      afterHideAction: () {
                        Navigator.pushReplacementNamed(
                          context,
                          SelectDeviceScreen.routeName,
                          arguments: measurementResult.measurementInfo,
                        );
                      },
                    );
                    break;
                }
              },
            );
          },
          builder: ((context, state) {
            final widget = state.when(
              init: () => const Text('Init'),
              searching: () => const Text('Searching'),
              found: (device) => const Text('Found'),
              notFound: () => const Text('Not Found'),
              pairing: () => const Text('Pairing'),
              paired: () => const Text('Paired'),
              connecting: () => const Text('Connecting'),
              connected: () => const Text('Connected'),
              disconnected: () => const Text('Disconnected'),
              verified: (device, deviceInfo) => const Text('Verified'),
              notVerified: () => const Text('Not Verified'),
              syncing: () => const Text('Syncing'),
              synced: (measurementInfo) => const Text('Synced'),
              error: (e) => Text(e.toString()),
            );

            return Column(
              children: [
                Expanded(
                  child: AvatarGlow(
                    glowColor: Colors.blue,
                    endRadius: 200.0,
                    duration: const Duration(milliseconds: 2000),
                    repeat: true,
                    showTwoGlows: true,
                    child: Material(
                      elevation: 0,
                      shape: const CircleBorder(),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        radius: 100.0,
                        child: SizedBox(
                          height: 50,
                          child: Center(child: widget),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
