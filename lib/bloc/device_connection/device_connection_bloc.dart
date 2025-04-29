import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bl_data/bl_connection.dart';
import 'package:scalesoft_app/bloc/device_connection/device_connection_bloc_event.dart';
import 'package:scalesoft_app/bloc/device_connection/device_connection_state.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/providers/device_db_provider.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/device_model.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/utils/events_constants.dart';
import 'package:scalesoft_app/utils/helpers/bt_connection_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

@injectable
class DeviceConnectionBloc
    extends Bloc<DeviceConnectionBlocEvent, DeviceConnectionState> {
  final BtConnectionHelper _btConnectionHelper;
  final ReportService _reportsService;
  final DeviceDbProvider _deviceDbProvider;

  DeviceCreateModel? _device;
  late final int _userId;
  late final MeasurementType _measurementType;
  bool shouldRequestPermission = true;
  bool? _searchStarted;
  bool tryConnect = false;
  BluetoothDevice? selectedBlDevice;
  late StreamSubscription stateSubscription;

  bool get reqModelPairing =>
      _device?.prototype.requiresPairing == true && _device?.isPaired != true;

  DeviceConnectionBloc(
    this._btConnectionHelper,
    this._reportsService,
    this._deviceDbProvider,
  ) : super(const DeviceConnectionState.init()) {
    on<DeviceConnectionBlocEvent>((event, emit) async {
      await event.when(
        //set device, userId and measurement type and transition to checkHwState
        init: (userId, measurementType, device) async {
          await WakelockPlus.enable();

          _device = device;

          _userId = userId;
          _measurementType = measurementType;

          add(const DeviceConnectionBlocEvent.checkHwState());
        },

        //check if all permissions are granted and if so start checking state
        //of bluetooth adapter
        //if not try to get the permissions granted
        //called when initializing this bloc or when app is resumed
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
              DeviceConnectionState.disabledBt(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            return;
          }

          if (await _btConnectionHelper.isBTPermissionsPermanentlyDenied()) {
            shouldRequestPermission = false;
            emit(
              DeviceConnectionState.noBtPermissions(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            return;
          }

          if (!await _btConnectionHelper.isBTPermissionsGranted()) {
            shouldRequestPermission = true;
            final hasPermissionsGranted =
                await _btConnectionHelper.requestForBTPermissions();
            if (!hasPermissionsGranted) {
              _reportsService.trackEvent(
                userId: _userId,
                severity: LogSeverity.warning,
                message: EventsConstants.eventNoBTPermissionsGranted,
              );
              emit(
                DeviceConnectionState.noBtPermissions(
                  timestamp: DateTime.now().microsecondsSinceEpoch,
                ),
              );
              return;
            }
          }
          shouldRequestPermission = false;

          if (!await _btConnectionHelper.hasLocationServiceEnabled()) {
            debugPrint('disabled location service !');
            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.warning,
              message: EventsConstants.eventDisabledLocationService,
            );
            emit(
              DeviceConnectionState.disabledLocationService(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            shouldRequestPermission = true;
            _searchStarted = false;
            return;
          }

          _searchStarted = true;
          //start checking bluetooth state
          FlutterBluePlus.adapterState.listen((btState) {
            add(DeviceConnectionBlocEvent.newBtState(btState));
          });
        },

        //called when bluetooth adapter changes state
        //starts search device event if adapter is on
        newBtState: (newBtState) {
          if (newBtState == BluetoothAdapterState.on) {
            add(const DeviceConnectionBlocEvent.searchDevice());
            return;
          }

          if (newBtState == BluetoothAdapterState.off) {
            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.warning,
              message: EventsConstants.eventBluetoothDisabled,
            );
            emit(
              DeviceConnectionState.disabledBt(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            return;
          }

          _reportsService.trackEvent(
            userId: _userId,
            severity: LogSeverity.warning,
            message: EventsConstants.eventNoBTPermissionsGranted,
          );
          emit(
            DeviceConnectionState.noBtPermissions(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );
        },

        // search for available devices matching _device identifier
        searchDevice: () async {
          _btConnectionHelper.syncMode = true;

          _reportsService.trackEvent(
            userId: _userId,
            severity: LogSeverity.info,
            message: EventsConstants.eventDeviceSearchingStart,
          );
          emit(
            DeviceConnectionState.searching(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );

          // debugPrint(_measurementType.toString());
          var scanResultStream =
              FlutterBluePlus.onScanResults.listenAndBuffer();

          if (!FlutterBluePlus.isScanningNow) {
            FlutterBluePlus.startScan();
          }

          await scanResultStream.firstWhere(
            (results) {
              if (results.isEmpty) {
                return false;
              }
              ScanResult? scanResult = results.firstWhereOrNull(
                (result) => result.advertisementData.advName.contains(
                  _device!.deviceIdentifier,
                ),
              );
              if (scanResult == null) {
                return false;
              }
              debugPrint(scanResult.advertisementData.serviceUuids.toString());
              selectedBlDevice = scanResult.device;
              debugPrint("found device: ${selectedBlDevice!.advName}");
              return true;
            },
          );

          await FlutterBluePlus.stopScan();

          if (selectedBlDevice == null) {
            emit(
              DeviceConnectionState.notFound(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            return;
          }

          tryConnect = true;
          stateSubscription =
              selectedBlDevice!.connectionState.listen((state) async {
            if (!tryConnect) {
              return;
            }
            if (state == BluetoothConnectionState.connected) {
              if (reqModelPairing) {
                add(const DeviceConnectionBlocEvent.pairDevice());
              } else {
                add(const DeviceConnectionBlocEvent.loadMeasurement());
              }
            }
            if (state == BluetoothConnectionState.disconnected) {
              // await Future.delayed(const Duration(seconds: 1));
              add(const DeviceConnectionBlocEvent.connectDevice());
            }
          });
        },

        connectDevice: () async {
          debugPrint("connecting device");
          await selectedBlDevice!.connect(autoConnect: false);

          _reportsService.trackEvent(
            userId: _userId,
            severity: LogSeverity.info,
            message: EventsConstants.eventDeviceConnected,
          );
        },

        pairDevice: () async {
          _reportsService.trackEvent(
            userId: _userId,
            severity: LogSeverity.info,
            message: EventsConstants.eventDevicePairing,
          );
          if (Platform.isAndroid) {
            selectedBlDevice!.createBond();
            await selectedBlDevice!.bondState.firstWhere((state) => state == BluetoothBondState.bonded);
          } else if (Platform.isIOS) {
            final recordAccessCp = Guid('2A52');

            final services = await selectedBlDevice!.discoverServices();

            final recordAccessCpCharacteristic = services
                .firstWhereOrNull(
                  (service) => service.serviceUuid == recordAccessCpServiceUuid,
            )
                ?.characteristics
                .firstWhereOrNull((characteristic) => characteristic.uuid == recordAccessCp);
            if (recordAccessCpCharacteristic == null){
              return;
            }

            try {
              await recordAccessCpCharacteristic.setNotifyValue(!recordAccessCpCharacteristic.isNotifying, timeout: 30);
              await recordAccessCpCharacteristic.write([0x00, 0x01], withoutResponse: false, timeout: 30);
            } on FlutterBluePlusException catch (e) {
              //Timeout error
              if (e.code == 1) return null;
              //Insufficient encryption error
              if (e.code == 15) return null;
            }
          }

          var deviceInfo =
              await _btConnectionHelper.requestDeviceInfo(selectedBlDevice!);
          deviceInfo ??=
              await _btConnectionHelper.requestDeviceInfo(selectedBlDevice!);
          if (deviceInfo == null) {
            emit(
              DeviceConnectionState.notVerified(
                timestamp: DateTime.now().microsecondsSinceEpoch,
                measurementResult: HwMeasurementResult(
                  resultState: ResultState.connectionError,
                  measurementDt: DateTime.now(),
                ),
              ),
            );
            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.info,
              message: EventsConstants.eventDeviceVerificationFailed,
            );
            return;
          }

          _reportsService.trackEvent(
            userId: _userId,
            severity: LogSeverity.info,
            message: EventsConstants.eventDeviceVerified,
          );

          emit(
            DeviceConnectionState.paired(
              timestamp: DateTime.now().microsecondsSinceEpoch,
              deviceInfo: deviceInfo,
            ),
          );
          _device =
              await _deviceDbProvider.markDeviceAsPaired(_userId, _device!);
          debugPrint("marked device as paired");

          _reportsService.trackEvent(
            userId: _userId,
            severity: LogSeverity.info,
            message: EventsConstants.eventDevicePaired,
          );
          emit(
            DeviceConnectionState.measuring(
              timestamp: DateTime.now().microsecondsSinceEpoch,
              deviceInfo: deviceInfo,
            ),
          );
          await selectedBlDevice!.connectionState.firstWhere(
              (state) => state == BluetoothConnectionState.disconnected);

          // Omron M7 tries to send data immediately after turning off so this stops that
          // I know it's ugly, what can you do
          tryConnect = false;
          await Future.delayed(const Duration(seconds: 1));
          tryConnect = true;
        },

        loadMeasurement: () async {
          // await stateSubscription.cancel();
          emit(
            DeviceConnectionState.syncing(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );
          var deviceInfo =
              await _btConnectionHelper.requestDeviceInfo(selectedBlDevice!);
          if (deviceInfo == null) {
            emit(
              DeviceConnectionState.notVerified(
                timestamp: DateTime.now().microsecondsSinceEpoch,
                measurementResult: HwMeasurementResult(
                  resultState: ResultState.connectionError,
                  measurementDt: DateTime.now(),
                ),
              ),
            );
            return;
          }
          var batteryInfo =
              await _btConnectionHelper.requestBatteryInfo(selectedBlDevice!);

          tryConnect = false;
          var blConnection =
              BlConnection(selectedBlDevice!);
          var hwMeasurementResult = await blConnection.getHwMeasurementResult();

          if (hwMeasurementResult.resultState != ResultState.success) {
            emit(
              DeviceConnectionState.synced(
                timestamp: DateTime.now().microsecondsSinceEpoch,
                measurementResult: hwMeasurementResult,
                deviceInfo: deviceInfo,
              ),
            );
            selectedBlDevice!.disconnect();
            return;
          }
          hwMeasurementResult.measurement!.userId = _userId;
          hwMeasurementResult.measurement!.deviceId =
              (_device as DeviceModel?)?.id;
          hwMeasurementResult.measurement!.measurementType = _measurementType;
          if (batteryInfo != null) {
            hwMeasurementResult.measurement!.batteryPercentage =
                batteryInfo.batteryLevel;
          }

          debugPrint("got measurement");
          emit(
            DeviceConnectionState.synced(
              timestamp: DateTime.now().microsecondsSinceEpoch,
              measurementResult: hwMeasurementResult,
              deviceInfo: deviceInfo,
            ),
          );
          _reportsService.trackEvent(
            userId: _userId,
            severity: LogSeverity.info,
            message: EventsConstants.eventDeviceSynced,
          );

          stateSubscription.cancel();
          selectedBlDevice!.disconnect();
        },

        //stops ble search, is only called from outside this class
        stopSearch: () async {
          await stopSearch();
          await stateSubscription.cancel();
        },
      );
    });
  }

  Future<void> stopSearch() async {
    _reportsService.trackEvent(
      userId: _userId,
      severity: LogSeverity.info,
      message: EventsConstants.eventDeviceSearchingStop,
    );
    await WakelockPlus.disable();
    await FlutterBluePlus.stopScan();
  }
}
