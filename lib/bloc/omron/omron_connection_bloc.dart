import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/bl_data/bl_connection.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc_event.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_state.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement/blood_pressure_value.dart';
import 'package:scalesoft_app/data/providers/device_db_provider.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/device_model.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/utils/events_constants.dart';
import 'package:scalesoft_app/utils/extensions/uint8_list_extension.dart';
import 'package:scalesoft_app/utils/helpers/bt_connection_helper.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

@injectable
class OmronConnectionBloc
    extends Bloc<OmronConnectionBlocEvent, OmronConnectionState> {
  final BtConnectionHelper _btConnectionHelper;
  final ReportService _reportsService;
  final DeviceDbProvider _deviceDbProvider;

  DeviceCreateModel? _device;
  late final int _userId;
  late final MeasurementType _measurementType;
  bool shouldRequestPermission = true;
  bool? _searchStarted;

  bool get reqModelPairing =>
      _device?.prototype.requiresPairing == true && _device?.isPaired != true;

  OmronConnectionBloc(
    this._btConnectionHelper,
    this._reportsService,
    this._deviceDbProvider,
  ) : super(const OmronConnectionState.init()) {
    on<OmronConnectionBlocEvent>((event, emit) async {
      await event.when(
        //set device, userId and measurement type and transition to checkHwState
        init: (userId, measurementType, device) async {
          await WakelockPlus.enable();

          _device = device;

          _userId = userId;
          _measurementType = measurementType;

          add(const OmronConnectionBlocEvent.checkHwState());
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
              OmronConnectionState.disabledBt(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            return;
          }

          if (await _btConnectionHelper.isBTPermissionsPermanentlyDenied()) {
            shouldRequestPermission = false;
            emit(
              OmronConnectionState.noBtPermissions(
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
                OmronConnectionState.noBtPermissions(
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
              OmronConnectionState.disabledLocationService(
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
            add(OmronConnectionBlocEvent.newBtState(btState));
          });
        },

        //called when bluetooth adapter changes state
        //starts search device event if adapter is on
        newBtState: (newBtState) async {
          if (newBtState == BluetoothAdapterState.on) {
            add(const OmronConnectionBlocEvent.searchDevice());
            return;
          }

          if (newBtState == BluetoothAdapterState.off) {
            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.warning,
              message: EventsConstants.eventBluetoothDisabled,
            );
            emit(
              OmronConnectionState.disabledBt(
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
            OmronConnectionState.noBtPermissions(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );
        },

        searchDevice: () async {
          _reportsService.trackEvent(
            userId: _userId,
            severity: LogSeverity.info,
            message: EventsConstants.eventDeviceSearchingStart,
          );

          emit(
            OmronConnectionState.searching(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );

          if (!FlutterBluePlus.isScanningNow) {
            FlutterBluePlus.startScan(
              withNames: ConfigurationConstants.supportedDevices
                  .map((devicePrototype) {
                return devicePrototype.bluetoothName;
              }).toList(),
              timeout: ConfigurationConstants.maxAllowedDeviceSearchingTime,
            );
          }
          var scanResultSubscription =
              FlutterBluePlus.onScanResults.listen((results) async {
            var scanResult = results.firstWhereOrNull(
              (result) =>
                  result.advertisementData.advName ==
                  _device!.prototype.bluetoothName,
            );
            if (scanResult == null) {
              return;
            }
            await FlutterBluePlus.stopScan();
            var selectedBlDevice = scanResult.device;
            emit(
              OmronConnectionState.found(
                timestamp: DateTime.now().microsecondsSinceEpoch,
                device: selectedBlDevice,
              ),
            );
            emit(
              OmronConnectionState.connecting(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            await selectedBlDevice.connect();
            _reportsService.trackEvent(
              userId: _userId,
              severity: LogSeverity.info,
              message: EventsConstants.eventDeviceConnected,
            );
            emit(
              OmronConnectionState.connected(
                  timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            final measurementUuid = Guid('2A35');
            var services = await selectedBlDevice.discoverServices();
            var characteristics = services
                .map((service) => service.characteristics)
                .expand((x) => x)
                .toList();
            var measurementCharacteristic = characteristics
                .firstWhere((chara) => chara.characteristicUuid == measurementUuid);
            var dataArray = List<List<int>>.empty(growable: true);
            measurementCharacteristic.onValueReceived.listen((data) {
              dataArray.add(data);
            },
            onDone: () {
              var data = dataArray.last;
              var measurement = MeasurementCreateModel(data.toInt8(16, 17), DateTime.now(), _measurementType);
              measurement.sys
            });
            // var blConnection = BlConnection(selectedBlDevice);

          });

          scanResultSubscription.cancel();
        },
        // searchDevice: () async {
        //   _reportsService.trackEvent(
        //     userId: _userId,
        //     severity: LogSeverity.info,
        //     message: EventsConstants.eventDeviceSearchingStart,
        //   );
        //
        //   emit(
        //     OmronConnectionState.searching(
        //       timestamp: DateTime.now().microsecondsSinceEpoch,
        //     ),
        //   );
        //
        //   final foundDevice = await _btConnectionHelper.searchDevice(
        //     serviceUuid: bloodPressureServiceUuid,                            // -------problem--------
        //     device: _device!,
        //     searchMode: reqModelPairing ? SearchMode.pairing : SearchMode.syncing,
        //     maxAllowedDeviceSearchingTime:
        //         reqModelPairing ? ConfigurationConstants.maxAllowedDeviceSearchingTime : null,
        //   );
        //
        //   if (foundDevice != null) {
        //     _reportsService.trackEvent(
        //       userId: _userId,
        //       severity: LogSeverity.info,
        //       message: EventsConstants.eventDeviceFound,
        //     );
        //     emit(
        //       OmronConnectionState.found(
        //         timestamp: DateTime.now().microsecondsSinceEpoch,
        //         device: foundDevice,
        //       ),
        //     );
        //     await connectToDevice(foundDevice, emit);
        //   } else {
        //     emit(
        //       OmronConnectionState.notFound(
        //         timestamp: DateTime.now().microsecondsSinceEpoch,
        //       ),
        //     );
        //   }
        // },

        //stops ble search, is only called from outside this class
        stopSearch: () async {
          await stopSearch();
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

//   /// If [_device] needs to be paired, this method will try to pair with it.
//   /// Otherwise an attempt to fetch the latest measurements available on the device will be made.
//   /// Returns true when the device was successfully paired (and this method should be called again to fetch measurements)
//   /// Returns false otherwise
  Future<bool> pairOrGetMeasurement(
    final BluetoothDevice blDevice,
    final DeviceInfo deviceInfo,
    Emitter<OmronConnectionState> emit,
  ) async {
    // Warning: Do not attempt to understand how, why, nor what this method (and the methods called by it) does.
    // Don't ask why the same method is used for pairing xor getting measurements - this is simply unknowable.
    if (reqModelPairing) {
      _reportsService.trackEvent(
        userId: _userId,
        severity: LogSeverity.info,
        message: EventsConstants.eventDevicePairing,
      );
      emit(
        OmronConnectionState.pairing(
          timestamp: DateTime.now().microsecondsSinceEpoch,
        ),
      );
    } else {
      _reportsService.trackEvent(
        userId: _userId,
        severity: LogSeverity.info,
        message: EventsConstants.eventDeviceSyncing,
      );
      emit(
        OmronConnectionState.syncing(
          timestamp: DateTime.now().microsecondsSinceEpoch,
        ),
      );
    }

    debugPrint('request device for data');
    final batteryInfo = await _btConnectionHelper.requestBatteryInfo(blDevice);
    final measurementResult = await _btConnectionHelper.requestBPData(          //-----------problem-----------
      blDevice,
      !reqModelPairing,
    );

    if (!reqModelPairing) {
      await WakelockPlus.disable();
    }

    if (measurementResult.resultState == ResultState.connectionError) {
      emit(
        OmronConnectionState.notFound(
          timestamp: DateTime.now().microsecondsSinceEpoch,
        ),
      );
      return false;
    }

    if (measurementResult.resultState == ResultState.success && reqModelPairing) {
      debugPrint(
        'device got success data when pairing [saving paired device]',
      );
      emit(
        OmronConnectionState.paired(
          timestamp: DateTime.now().microsecondsSinceEpoch,
          deviceInfo: deviceInfo,
        ),
      );

      _reportsService.trackEvent(
        userId: _userId,
        severity: LogSeverity.info,
        message: EventsConstants.eventDevicePaired,
      );

      //save paired device
      _device = await _deviceDbProvider.markDeviceAsPaired(_userId, _device!);
      return true;
    }

    if (measurementResult.resultState == ResultState.success && measurementResult.measurementInfo != null) {
      debugPrint('device got success data');
      final measurementInfo = measurementResult.measurementInfo!;

      final measurement = MeasurementCreateModel(
        _userId,
        measurementResult.measurementDt,
        _measurementType,
        deviceId: (_device as DeviceModel?)?.id,
        bloodPressure: BloodPressureValue(
          systolic: measurementInfo.systolic,
          diastolic: measurementInfo.diastolic,
        ),
        heartRate: measurementInfo.pulseRate,
        batteryPercentage: batteryInfo?.batteryLevel,
      );

      _reportsService.trackEvent(
        userId: _userId,
        severity: LogSeverity.info,
        message: EventsConstants.eventDeviceSynced,
      );
      emit(
        OmronConnectionState.synced(
          timestamp: DateTime.now().microsecondsSinceEpoch,
          measurementResult: measurementResult.copyWith(measurement: measurement),
          deviceInfo: deviceInfo,
        ),
      );
    } else if (measurementResult.resultState == ResultState.noData) {
      debugPrint('device got empty data');
      emit(
        OmronConnectionState.synced(
          timestamp: DateTime.now().microsecondsSinceEpoch,
          measurementResult: measurementResult,
          deviceInfo: deviceInfo,
        ),
      );
    }

    return false;
  }
//
//   Future<void> measureAndSync(
//     BluetoothDevice blDevice,
//     DeviceInfo deviceInfo,
//     Emitter<OmronConnectionState> emit,
//   ) async {
//     final wasPaired = await pairOrGetMeasurement(
//       blDevice,
//       deviceInfo,
//       emit,
//     );
//     //if device was about pairing before, then now we are expecting measurement data results,
//     if (wasPaired) {
//       //straight after pairing process, device should be turned off,
//       //then we can start search for device again in metering mode
//       await Future.delayed(const Duration(seconds: 2));
//       emit(
//         OmronConnectionState.measuring(
//           timestamp: DateTime.now().microsecondsSinceEpoch,
//           deviceInfo: deviceInfo,
//         ),
//       );
//       await Future.delayed(const Duration(seconds: 3));
//       final foundDevice = await _btConnectionHelper.searchDevice(               //--------problem-------
//         serviceUuid: bloodPressureServiceUuid,
//         device: _device!,
//         searchMode: reqModelPairing ? SearchMode.pairing : SearchMode.syncing,
//       );
//       if (foundDevice != null) {
//         _reportsService.trackEvent(
//           userId: _userId,
//           severity: LogSeverity.info,
//           message: EventsConstants.eventDeviceFound,
//         );
//         try {
//           await foundDevice.connect(autoConnect: false);
//         } catch (e) {
//           debugPrint('dev is already connected');
//           await foundDevice.disconnect();
//           await foundDevice.connect(autoConnect: false);
//         }
//         await pairOrGetMeasurement(foundDevice, deviceInfo, emit);
//       }
//     }
//   }
//
//   Future<DeviceInfo?> verifyDevice(BluetoothDevice blDevice, Emitter<OmronConnectionState> emit) async {
//     final deviceInfo = await _btConnectionHelper.requestDeviceInfo(blDevice);
//
//     if (deviceInfo != null) {
//       _reportsService.trackEvent(
//         userId: _userId,
//         severity: LogSeverity.info,
//         message: EventsConstants.eventDeviceVerified,
//       );
//       // emit(
//       //   OmronConnectionState.verified(
//       //     timestamp: DateTime.now().microsecondsSinceEpoch,
//       //     device: blDevice,
//       //     deviceInfo: deviceInfo,
//       //   ),
//       // );
//       return deviceInfo;
//     } else {
//       _reportsService.trackEvent(
//         userId: _userId,
//         severity: LogSeverity.error,
//         message: EventsConstants.eventDeviceVerificationFailed,
//       );
//       emit(
//         OmronConnectionState.notVerified(
//           timestamp: DateTime.now().microsecondsSinceEpoch,
//           measurementResult: HwMeasurementResult(
//             resultState: ResultState.connectionError,
//             measurementDt: DateTime.now(),
//           ),
//         ),
//       );
//       await stopSearch();
//
//       return null;
//     }
//   }
//
//   Future<void> connectToDevice(
//     BluetoothDevice device,
//     Emitter<OmronConnectionState> emit,
//   ) async {
//     emit(
//       OmronConnectionState.connecting(
//         timestamp: DateTime.now().microsecondsSinceEpoch,
//       ),
//     );
//
//     try {
//       await device.connect(autoConnect: false);
//       emit(
//         OmronConnectionState.connected(
//           timestamp: DateTime.now().microsecondsSinceEpoch,
//         ),
//       );
//       _reportsService.trackEvent(
//         userId: _userId,
//         severity: LogSeverity.info,
//         message: EventsConstants.eventDeviceConnected,
//       );
//     } catch (e) {
//       debugPrint('dev is already connected');
//       await device.disconnect();
//       await device.connect(autoConnect: false);
//     }
//
//     final deviceInfo = await verifyDevice(device, emit);
//
//     if (deviceInfo != null) {
//       await measureAndSync(device, deviceInfo, emit);
//     }
//   }
// }
