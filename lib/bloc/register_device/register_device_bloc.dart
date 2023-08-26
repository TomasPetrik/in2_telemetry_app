import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/device_to_register.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/report/report.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_event.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/repositories/device_repository.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/utils/events_constants.dart';
import 'package:scalesoft_app/utils/helpers/bt_connection_helper.dart';
import 'package:wakelock/wakelock.dart';

@injectable
class RegisterDeviceBloc
    extends Bloc<RegisterDeviceBlocEvent, RegisterDeviceBlocState> {
  final BtConnectionHelper _btConnectionHelper;
  final AccountDbProvider _accountDbProvider;
  final DeviceRepository _deviceRepository;
  final ReportService _reportsService;

  late final UserAccount _userAccount;
  late final bool _onlyPairingMode;

  RegisterDeviceBloc(
    this._btConnectionHelper,
    this._accountDbProvider,
    this._deviceRepository,
    this._reportsService,
  ) : super(const RegisterDeviceBlocState.init()) {
    on<RegisterDeviceBlocEvent>((event, emit) async {
      await event.when(
        init: (String userId, bool? onlyPairingMode) async {
          _userAccount = _accountDbProvider.get(userId)!;
          _onlyPairingMode = onlyPairingMode ?? false;
          await Wakelock.enable();

          final btState = await FlutterBluePlus.adapterState.first;

          if (btState == BluetoothAdapterState.off) {
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.warning,
              message: EventsConstants.eventBluetoothDisabled,
            );
            emit(const RegisterDeviceBlocState.disabledBt());
          } else {
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.warning,
              message: EventsConstants.eventNoBTPermissionsGranted,
            );
            emit(const RegisterDeviceBlocState.noBtPermissions());
          }

          final hasPermissionsGranted =
              await _btConnectionHelper.hasPermissionsGranted();
          if (!hasPermissionsGranted) {
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.warning,
              message: EventsConstants.eventNoBTPermissionsGranted,
            );
            emit(const RegisterDeviceBlocState.noBtPermissions());
          }

          _startCheckingBtState();
        },
        newBtState: (BluetoothAdapterState newBtState) {
          if (newBtState == BluetoothAdapterState.on) {
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.warning,
              message: EventsConstants.eventBluetoothDisabled,
            );
            add(const RegisterDeviceBlocEvent.searchDevices());
          } else if (newBtState == BluetoothAdapterState.off) {
            emit(const RegisterDeviceBlocState.disabledBt());
          } else {
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.warning,
              message: EventsConstants.eventNoBTPermissionsGranted,
            );
            emit(const RegisterDeviceBlocState.noBtPermissions());
          }
        },
        searchDevices: () async {
          _reportsService.trackEvent(
            userAccount: _userAccount,
            severity: Severity.warning,
            message: EventsConstants.eventDeviceSearchingStart,
          );
          emit(
            RegisterDeviceBlocState.searching(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );
          _btConnectionHelper.searchDevicesByService(
            serviceUuid: bloodPressureServiceUuid,
            onlyPairingMode: _onlyPairingMode,
            onResult: (btDevices) {
              add(
                RegisterDeviceBlocEvent.notifyAboutNewDevices(
                  timestamp: DateTime.now().microsecondsSinceEpoch,
                  foundDevices: btDevices,
                ),
              );
            },
          );
        },
        notifyAboutNewDevices: (timestamp, foundDevices) async {
          emit(
            RegisterDeviceBlocState.searching(
              timestamp: timestamp,
              devices: foundDevices,
            ),
          );
        },
        stopSearch: () async {
          _reportsService.trackEvent(
            userAccount: _userAccount,
            severity: Severity.warning,
            message: EventsConstants.eventDeviceSearchingStop,
          );
          await Wakelock.disable();
          FlutterBluePlus.stopScan();
        },
        selectDevice: (Device device) async {
          await Wakelock.disable();
          await FlutterBluePlus.stopScan();
          emit(RegisterDeviceBlocState.popDevice(device));
        },
        registerDevice: (userAccount, device, assignedIdentifier) async {
          try {
            //1. Load device models for lookup what's the device id
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.info,
              message: EventsConstants.eventDeviceRegistering,
            );
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

            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.info,
              message: EventsConstants.eventDeviceRegistered,
            );
            emit(const RegisterDeviceBlocState.deviceRegistered());
          } on DioException catch (exception) {
            if (exception.response?.statusCode == 500) {
              _reportsService.trackEvent(
                userAccount: _userAccount,
                severity: Severity.warning,
                message: EventsConstants.eventDeviceAlreadyRegistered,
              );
              emit(
                RegisterDeviceBlocState.deviceAlreadyRegistered(UniqueKey()),
              );
            } else {
              _reportsService.trackEvent(
                userAccount: _userAccount,
                severity: Severity.warning,
                message: EventsConstants.eventDeviceRegistrationFailed,
              );
              emit(RegisterDeviceBlocState.failedRegistration(UniqueKey()));
            }
          }
        },
      );
    });
  }
  void _startCheckingBtState() {
    FlutterBluePlus.adapterState.listen((btState) {
      add(RegisterDeviceBlocEvent.newBtState(btState));
    });
  }
}
