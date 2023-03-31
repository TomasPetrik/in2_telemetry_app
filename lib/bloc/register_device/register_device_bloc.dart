import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_event.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_state.dart';
import 'package:scalesoft_app/ui/screens/constants.dart';
import 'package:scalesoft_app/utils/helpers/bt_connection_helper.dart';

@injectable
class RegisterDeviceBloc
    extends Bloc<RegisterDeviceBlocEvent, RegisterDeviceBlocState> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  RegisterDeviceBloc() : super(const RegisterDeviceBlocState.init()) {
    on<RegisterDeviceBlocEvent>((event, emit) async {
      await event.when(
        init: () async {
          final btState = await flutterBlue.state.first;

          if (btState == BluetoothState.off) {
            emit(const RegisterDeviceBlocState.disabledBt());
          } else {
            emit(const RegisterDeviceBlocState.noBtPermissions());
          }

          final hasPermissionsGranted =
              await BtConnectionHelper.hasPermissionsGranted();
          if (!hasPermissionsGranted) {
            emit(const RegisterDeviceBlocState.noBtPermissions());
          }

          _startCheckingBtState();
        },
        newBtState: (BluetoothState newBtState) {
          if (newBtState == BluetoothState.on) {
            add(const RegisterDeviceBlocEvent.searchDevices());
          } else if (newBtState == BluetoothState.off) {
            emit(const RegisterDeviceBlocState.disabledBt());
          } else {
            emit(const RegisterDeviceBlocState.noBtPermissions());
          }
        },
        searchDevices: () async {
          emit(const RegisterDeviceBlocState.searching());
          BtConnectionHelper.searchDevicesByService(
            serviceUuid: bloodPressureServiceUuid,
            onResult: (btDevices) {
              add(RegisterDeviceBlocEvent.notifyAboutNewDevices(btDevices));
            },
          );
        },
        notifyAboutNewDevices: (foundDevices) async {
          emit(
            RegisterDeviceBlocState.searching(
              devices: foundDevices,
            ),
          );
        },
        stopSearch: () {
          flutterBlue.stopScan();
        },
      );
    });
  }
  void _startCheckingBtState() {
    FlutterBluePlus.instance.state.listen((btState) {
      add(RegisterDeviceBlocEvent.newBtState(btState));
    });
  }
}
