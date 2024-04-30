import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/device/device_create_contract.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_contract.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_event.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_state.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/repositories/device_repository.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/utils/events_constants.dart';
import 'package:scalesoft_app/utils/helpers/bt_connection_helper.dart';
import 'package:wakelock/wakelock.dart';

@injectable
class RegisterDeviceBloc extends Bloc<RegisterDeviceBlocEvent, RegisterDeviceBlocState> {
  final BtConnectionHelper _btConnectionHelper;
  final DeviceRepository _deviceRepository;
  final ReportService _reportsService;

  late final int _userId;
  late final bool _onlyPairingMode;
  bool shouldRequestPermission = true;
  bool? _searchStarted;

  RegisterDeviceBloc(
    this._btConnectionHelper,
    this._deviceRepository,
    this._reportsService,
  ) : super(const RegisterDeviceBlocState.init()) {
    on<RegisterDeviceBlocEvent>((event, emit) async {
      await event.when(
        init: (int userId, bool? onlyPairingMode) async {
          await Wakelock.enable();
          _userId = userId;
          _onlyPairingMode = onlyPairingMode ?? false;

          add(const RegisterDeviceBlocEvent.checkHwState());
        },
        checkHwState: () async {
          if (_searchStarted == true) {
            return;
          }

          final btState = await FlutterBluePlus.adapterState.first;

          if (btState == BluetoothAdapterState.off ||
              btState == BluetoothAdapterState.unauthorized ||
              btState == BluetoothAdapterState.turningOff) {
            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.warning,
              message: EventsConstants.eventBluetoothDisabled,
            );
            emit(
              RegisterDeviceBlocState.disabledBt(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            return;
          }

          final isBTPermissionsPermanentylDenied = await _btConnectionHelper.isBTPermissionsPermanentylDenied();

          if (isBTPermissionsPermanentylDenied) {
            shouldRequestPermission = true;
            emit(
              RegisterDeviceBlocState.noBtPermissions(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            return;
          } else if (await _btConnectionHelper.isBTPermissionsGranted()) {
            shouldRequestPermission = false;
          } else {
            shouldRequestPermission = true;
            final hasPermissionsGranted = await _btConnectionHelper.requestForBTPermissions();
            if (!hasPermissionsGranted) {
              _reportsService.trackEvent(
                userId: _userId,
                severity: LogSeverity.warning,
                message: EventsConstants.eventNoBTPermissionsGranted,
              );
              emit(
                RegisterDeviceBlocState.noBtPermissions(
                  timestamp: DateTime.now().microsecondsSinceEpoch,
                ),
              );
              return;
            }
          }

          final hasLocationServiceEnabled = await _btConnectionHelper.hasLocationServiceEnabled();
          if (!hasLocationServiceEnabled) {
            debugPrint('disabled location service !');
            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.warning,
              message: EventsConstants.eventDisabledLocalizationService,
            );
            emit(
              RegisterDeviceBlocState.disabledLocalizationService(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            shouldRequestPermission = true;
            _searchStarted = false;
          } else {
            _searchStarted = false;
            _startCheckingBtState();
          }
        },
        newBtState: (BluetoothAdapterState newBtState) async {
          if (newBtState == BluetoothAdapterState.on) {
            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.warning,
              message: EventsConstants.eventBluetoothDisabled,
            );
            add(const RegisterDeviceBlocEvent.searchDevices());
          } else if (newBtState == BluetoothAdapterState.off) {
            emit(
              RegisterDeviceBlocState.disabledBt(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
          } else {
            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.warning,
              message: EventsConstants.eventNoBTPermissionsGranted,
            );
            emit(
              RegisterDeviceBlocState.noBtPermissions(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
          }
        },
        searchDevices: () async {
          _reportsService.trackEvent(
            userId: _userId,
            severity: LogSeverity.warning,
            message: EventsConstants.eventDeviceSearchingStart,
          );
          emit(
            RegisterDeviceBlocState.searching(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );
          _btConnectionHelper.searchDevicesByService(
            serviceUuids: [bloodPressureServiceUuid, heartRateServiceUuid],
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
            userId: _userId,
            severity: LogSeverity.warning,
            message: EventsConstants.eventDeviceSearchingStop,
          );
          await Wakelock.disable();
          await FlutterBluePlus.stopScan();
        },
        selectDevice: (SourceDeviceContract device) async {
          await Wakelock.disable();
          await FlutterBluePlus.stopScan();
          emit(RegisterDeviceBlocState.popDevice(device));
        },
        registerDevice: (userAccount, device, assignedIdentifier) async {
          try {
            //1. Load device models for lookup what's the device id
            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.info,
              message: EventsConstants.eventDeviceRegistering,
            );
            emit(const RegisterDeviceBlocState.registering());

            final deviceModels = await _deviceRepository.getDeviceModels(
              userId: _userId,
            );

            final int deviceModelId = deviceModels
                .firstWhere(
                  (deviceModel) =>
                      deviceModel.manufacturer == device.deviceManufacturer &&
                      deviceModel.modelName == device.modelName,
                )
                .id;

            final deviceToRegister = DeviceCreateContract(
              deviceModelId: deviceModelId,
              assignedIdentifier: assignedIdentifier,
              deviceIdentifier: device.deviceIdentifier,
              // bluetoothAddress: TODO
            );

            await _deviceRepository.registerDevice(
              userId: _userId,
              deviceToRegister: deviceToRegister,
            );

            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.info,
              message: EventsConstants.eventDeviceRegistered,
            );
            emit(const RegisterDeviceBlocState.deviceRegistered());
          } on DioException catch (exception) {
            if (exception.response?.statusCode == 500) {
              _reportsService.trackEvent(
                userId: _userId,
                severity: LogSeverity.warning,
                message: EventsConstants.eventDeviceAlreadyRegistered,
              );
              emit(
                RegisterDeviceBlocState.deviceAlreadyRegistered(UniqueKey()),
              );
            } else {
              _reportsService.trackEvent(
                userId: _userId,
                severity: LogSeverity.warning,
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
