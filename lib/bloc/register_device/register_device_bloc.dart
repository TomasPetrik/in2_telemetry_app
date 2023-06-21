import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/device_to_register.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_event.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_state.dart';
import 'package:scalesoft_app/repositories/device_repository.dart';
import 'package:scalesoft_app/ui/routers/routes/register_device_detail_route.dart';
import 'package:scalesoft_app/utils/helpers/bt_connection_helper.dart';
import 'package:wakelock/wakelock.dart';

@injectable
class RegisterDeviceBloc
    extends Bloc<RegisterDeviceBlocEvent, RegisterDeviceBlocState> {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final DeviceRepository _deviceRepository;
  late BuildContext context;

  RegisterDeviceBloc(
    this._deviceRepository,
  ) : super(const RegisterDeviceBlocState.init()) {
    on<RegisterDeviceBlocEvent>((event, emit) async {
      await event.when(
        init: (BuildContext context) async {
          this.context = context;
          await Wakelock.enable();

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
        stopSearch: () async {
          await Wakelock.disable();
          _flutterBlue.stopScan();
        },
        openDeviceDetail: (Map<String, String> params) async {
          _flutterBlue.stopScan();
          await Wakelock.disable().then(
            (_) => GoRouter.of(context).replaceNamed(
              RegisterDeviceDetailRoute.name,
              params: params,
            ),
          );
        },
        registerDevice: (userAccount, device, assignedIdentifier) async {
          try {
            //1. Load device models for lookup what's the device id
            emit(const RegisterDeviceBlocState.registering());

            final deviceModels = await _deviceRepository.getDeviceModels(
              userAccount: userAccount,
            );

            final int deviceModelId = deviceModels
                .firstWhere(
                  (deviceModel) =>
                      deviceModel.manufacturer == device.deviceManufacturer &&
                      deviceModel.modelName == device.modelName,
                )
                .id;

            final deviceToRegister = DeviceToRegister(
              deviceModelId: deviceModelId,
              assignedIdentifier: assignedIdentifier,
              deviceIdentifier: device.deviceIdentifier!,
            );

            await _deviceRepository.registerDevice(
              userAccount: userAccount,
              deviceToRegister: deviceToRegister,
            );

            emit(const RegisterDeviceBlocState.deviceRegistered());
          } on DioError catch (dioError) {
            if (dioError.response?.statusCode == 500) {
              emit(
                RegisterDeviceBlocState.deviceAlreadyRegistered(UniqueKey()),
              );
            } else {
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
