import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/measurement/composed_int_value.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/source_device_info.dart';
import 'package:scalesoft_app/api/model/report/report.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc_event.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_state.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:scalesoft_app/utils/events_constants.dart';
import 'package:scalesoft_app/utils/helpers/bt_connection_helper.dart';
import 'package:wakelock/wakelock.dart';

@injectable
class OmronConnectionBloc
    extends Bloc<OmronConnectionBlocEvent, OmronConnectionState> {
  final BtConnectionHelper _btConnectionHelper;
  final AccountDbProvider _accountDbProvider;
  final PairedDevicesDbProvider _pairedDevicesDbProvider;
  final ReportService _reportsService;

  Device? _device;
  late final UserAccount _userAccount;
  late final MeasurementType _measurementType;

  bool get reqModelPairing =>
      _device?.reqPairing == true && _device?.wasPaired != true;

  String getDevIdFromName(String localName) {
    String devId = localName;

    final supportedDev = Constants.supportedDevices.firstWhere(
      (dev) =>
          localName.toLowerCase().contains(dev.bluetoothName!.toLowerCase()),
    );

    if (supportedDev.deviceModelType == DeviceModelType.omronM7) {
      devId = devId.split('_').last;
    }
    return devId;
  }

  OmronConnectionBloc(
    this._btConnectionHelper,
    this._accountDbProvider,
    this._pairedDevicesDbProvider,
    this._reportsService,
  ) : super(const OmronConnectionState.init()) {
    on<OmronConnectionBlocEvent>((event, emit) async {
      Future<DeviceInfo?> verifyDevice(
        BluetoothDevice blDevice,
        String localName,
      ) async {
        final deviceInfo =
            await _btConnectionHelper.requestDeviceInfo(blDevice);
        //deviceInfo?.advData = advertisementData;

        final batteryInfo =
            await _btConnectionHelper.requestBatteryInfo(blDevice);

        deviceInfo?.batteryInfo = batteryInfo;

        if (deviceInfo != null) {
          _reportsService.trackEvent(
            userAccount: _userAccount,
            severity: Severity.info,
            message: EventsConstants.eventDeviceVerified,
          );
          emit(
            OmronConnectionState.verified(
              timestamp: DateTime.now().microsecondsSinceEpoch,
              device: blDevice,
              deviceInfo: deviceInfo,
            ),
          );
          return deviceInfo;
        } else {
          _reportsService.trackEvent(
            userAccount: _userAccount,
            severity: Severity.error,
            message: EventsConstants.eventDeviceVerificationFailed,
          );
          emit(
            OmronConnectionState.notVerified(
              timestamp: DateTime.now().microsecondsSinceEpoch,
              measurementResult: HwMeasurementResult(
                resultState: ResultState.connectionError,
                measurementDt: DateTime.now(),
                devId: getDevIdFromName(localName),
              ),
            ),
          );
          add(const OmronConnectionBlocEvent.stopSearch());

          return null;
        }
      }

      Future<Device?> measureAndSync(
        final BluetoothDevice blDevice,
        final DeviceInfo deviceInfo,
        final String localName,
      ) async {
        if (reqModelPairing) {
          _reportsService.trackEvent(
            userAccount: _userAccount,
            severity: Severity.info,
            message: EventsConstants.eventDevicePairing,
          );
          emit(
            OmronConnectionState.pairing(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );
        } else {
          _reportsService.trackEvent(
            userAccount: _userAccount,
            severity: Severity.info,
            message: EventsConstants.eventDeviceSyncing,
          );
          emit(
            OmronConnectionState.syncing(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );
        }

        debugPrint('request device for data');
        final measurementResult = await _btConnectionHelper.requestBPData(
          blDevice,
          !reqModelPairing,
          getDevIdFromName(localName),
        );

        if (!reqModelPairing) {
          await Wakelock.disable();
        }

        if (measurementResult.resultState == ResultState.connectionError) {
          emit(
            OmronConnectionState.notFound(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );
          return null;
        } else if (measurementResult.resultState == ResultState.success) {
          debugPrint('device got success data');
          final measurementInfo = measurementResult.measurementInfo;

          final supportedDev = Constants.supportedDevices.firstWhere(
            (dev) => localName
                .toLowerCase()
                .contains(dev.bluetoothName!.toLowerCase()),
          );

          var devId = getDevIdFromName(localName);

          Measurement? measurement = Measurement(
            patientMuid: _userAccount.user.muid,
            measurementType: _measurementType,
            measurementDateTime: measurementResult.measurementDt,
            sourceDeviceWithMetadata: SourceDeviceInfo(
              sourceDevice: Device(
                deviceIdentifier: devId,
                modelName: supportedDev.modelName,
                deviceManufacturer: supportedDev.deviceManufacturer,
              ),
              batteryPercentage: deviceInfo.batteryInfo?.batteryLevel,
            ),
            bloodPressure: BloodPressureValue(
              systolic: measurementInfo?.systolic,
              diastolic: measurementInfo?.diastolic,
            ),
            heartRate: measurementInfo?.pulseRate,
          );

          emit(
            OmronConnectionState.synced(
              timestamp: DateTime.now().microsecondsSinceEpoch,
              measurementResult:
                  measurementResult.copyWith(measurement: measurement),
              deviceInfo: deviceInfo,
            ),
          );

          if (reqModelPairing) {
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.info,
              message: EventsConstants.eventDevicePaired,
            );
          } else {
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.info,
              message: EventsConstants.eventDeviceSynced,
            );
          }
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

        if (measurementResult.resultState == ResultState.success &&
            reqModelPairing) {
          debugPrint(
            'device got success data when pairing [saving paired device]',
          );
          emit(
            OmronConnectionState.paired(
              timestamp: DateTime.now().microsecondsSinceEpoch,
              deviceInfo: deviceInfo,
            ),
          );

          //save paired device
          if (measurementResult.resultState != ResultState.connectionError) {
            var devId = getDevIdFromName(localName);

            final pairedDevice = _device!.copyWith(
              deviceIdentifier: devId,
              wasPaired: true,
              addedAt: DateTime.now(),
            );

            await _pairedDevicesDbProvider.add(pairedDevice);
            return pairedDevice;
          }
        }

        return null;
      }

      Future<void> connectToDevice(
        BluetoothDevice device,
        String localName,
      ) async {
        emit(
          OmronConnectionState.connecting(
            timestamp: DateTime.now().microsecondsSinceEpoch,
          ),
        );

        try {
          await device.connect(autoConnect: false);
          emit(
            OmronConnectionState.connected(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );
        } catch (e) {
          debugPrint('dev is already connected');
          await device.disconnect();
          await device.connect(autoConnect: false);

          add(OmronConnectionBlocEvent.verifyDevice(device, localName));
        }

        _reportsService.trackEvent(
          userAccount: _userAccount,
          severity: Severity.info,
          message: EventsConstants.eventDeviceConnected,
        );

        add(OmronConnectionBlocEvent.verifyDevice(device, localName));
      }

      await event.when(
        init: (userId, measurementType, device) async {
          await Wakelock.enable();

          _device = device;
          _userAccount = _accountDbProvider.get(userId)!;
          _measurementType = measurementType;
          final btState = await FlutterBluePlus.adapterState.first;

          if (btState == BluetoothAdapterState.off) {
            emit(
              OmronConnectionState.disabledBt(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.warning,
              message: EventsConstants.eventBluetoothDisabled,
            );
          } else {
            emit(
              OmronConnectionState.noBtPermissions(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
          }

          final hasPermissionsGranted =
              await _btConnectionHelper.hasPermissionsGranted();
          if (!hasPermissionsGranted) {
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.warning,
              message: EventsConstants.eventNoBTPermissionsGranted,
            );
            emit(
              OmronConnectionState.noBtPermissions(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
          }

          _startCheckingBtState();
        },
        newBtState: (newBtState) async {
          if (newBtState == BluetoothAdapterState.on) {
            add(const OmronConnectionBlocEvent.checkDeviceAvailability());
          } else if (newBtState == BluetoothAdapterState.off) {
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.warning,
              message: EventsConstants.eventBluetoothDisabled,
            );
            emit(
              OmronConnectionState.disabledBt(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
          } else {
            _reportsService.trackEvent(
              userAccount: _userAccount,
              severity: Severity.warning,
              message: EventsConstants.eventNoBTPermissionsGranted,
            );
            emit(
              OmronConnectionState.noBtPermissions(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
          }
        },
        checkDeviceAvailability: () async {
          add(const OmronConnectionBlocEvent.searchDevice());
        },
        searchDevice: () async {
          _reportsService.trackEvent(
            userAccount: _userAccount,
            severity: Severity.info,
            message: EventsConstants.eventDeviceSearchingStart,
          );
          emit(
            OmronConnectionState.searching(
              timestamp: DateTime.now().microsecondsSinceEpoch,
            ),
          );
          final foundDevice = await _btConnectionHelper.searchDevice(
            serviceUuid: bloodPressureServiceUuid,
            device: _device!,
            searchMode:
                reqModelPairing ? SearchMode.pairing : SearchMode.syncing,
            maxAllowedDeviceSearchingTime: reqModelPairing
                ? Constants.maxAllowedDeviceSearchingTime
                : null,
          );
          if (foundDevice != null) {
            add(
              OmronConnectionBlocEvent.foundDevice(
                foundDevice.device,
                foundDevice.localName,
              ),
            );
            add(
              OmronConnectionBlocEvent.connectToDevice(
                foundDevice.device,
                foundDevice.localName,
              ),
            );
          } else {
            emit(
              OmronConnectionState.notFound(
                timestamp: DateTime.now().microsecondsSinceEpoch,
              ),
            );
          }
        },
        stopSearch: () async {
          _reportsService.trackEvent(
            userAccount: _userAccount,
            severity: Severity.info,
            message: EventsConstants.eventDeviceSearchingStop,
          );
          await Wakelock.disable();
          FlutterBluePlus.stopScan();
        },
        connectToDevice: (device, localName) async {
          await connectToDevice(device, localName);
        },
        verifyDevice: (device, localName) async {
          final deviceInfo = await verifyDevice(device, localName);

          if (deviceInfo != null) {
            add(
              OmronConnectionBlocEvent.measureAndSync(
                device,
                deviceInfo,
                localName,
              ),
            );
          }
        },
        measureAndSync: (blDevice, deviceInfo, localName) async {
          final pairedDevice = await measureAndSync(
            blDevice,
            deviceInfo,
            localName,
          );

          //if device was about pairing before, then now we are expecting measurement data results,
          if (pairedDevice != null) {
            //updating device containing mac address to do syncing in future (no pairing anymore)
            _device = pairedDevice;
            //straight after pairing process, device should be turned off,
            //then we can start search for device again in metering mode
            await Future.delayed(const Duration(seconds: 5));
            final foundDevice = await _btConnectionHelper.searchDevice(
              serviceUuid: bloodPressureServiceUuid,
              device: _device!,
              searchMode:
                  reqModelPairing ? SearchMode.pairing : SearchMode.syncing,
            );
            if (foundDevice != null) {
              _reportsService.trackEvent(
                userAccount: _userAccount,
                severity: Severity.info,
                message: EventsConstants.eventDeviceFound,
              );
              await foundDevice.device.connect(autoConnect: false);
              await measureAndSync(foundDevice.device, deviceInfo, localName);
            }
          }
        },
        foundDevice: (device, localName) async {
          _reportsService.trackEvent(
            userAccount: _userAccount,
            severity: Severity.info,
            message: EventsConstants.eventDeviceFound,
          );
          emit(
            OmronConnectionState.found(
              timestamp: DateTime.now().microsecondsSinceEpoch,
              device: device,
            ),
          );
        },
      );
    });
  }

  void _startCheckingBtState() {
    FlutterBluePlus.adapterState.listen((btState) {
      add(OmronConnectionBlocEvent.newBtState(btState));
    });
  }
}
