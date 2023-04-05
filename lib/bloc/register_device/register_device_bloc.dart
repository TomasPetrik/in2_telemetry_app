import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_event.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_state.dart';
import 'package:scalesoft_app/repositories/care_plans_repository.dart';
import 'package:scalesoft_app/ui/screens/constants.dart';
import 'package:scalesoft_app/utils/helpers/bt_connection_helper.dart';
import 'package:scalesoft_app/utils/helpers/dio_helper.dart';

@injectable
class RegisterDeviceBloc
    extends Bloc<RegisterDeviceBlocEvent, RegisterDeviceBlocState> {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final CarePlansRepository _carePlansRepository;

  RegisterDeviceBloc(
    this._carePlansRepository,
  ) : super(const RegisterDeviceBlocState.init()) {
    on<RegisterDeviceBlocEvent>((event, emit) async {
      await event.when(
        init: () async {
          final btState = await _flutterBlue.state.first;

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
          _flutterBlue.stopScan();
        },
        registerDevice: (userAccount, device) async {
          try {
            await _carePlansRepository.registerDevice(
              userAccount: userAccount,
              device: device,
            );

            emit(const RegisterDeviceBlocState.deviceRegistered());
          } on DioError catch (dioError) {
            if (dioError.response?.statusCode == 400 ||
                dioError.response?.statusCode == 403) {
              emit(
                RegisterDeviceBlocState.deviceAlreadyRegistered(UniqueKey()),
              );
            } else if (dioError.response?.statusCode == 404 ||
                DioHelper.isNoInternet(dioError)) {
              emit(RegisterDeviceBlocState.failedRegistration(UniqueKey()));
            }
          }
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
