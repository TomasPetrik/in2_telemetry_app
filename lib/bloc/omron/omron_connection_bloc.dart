import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/measurement/composed_int_value.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/source_device_info.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc_event.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:scalesoft_app/utils/helpers/bt_connection_helper.dart';
import 'package:wakelock/wakelock.dart';

@injectable
class OmronConnectionBloc
    extends Bloc<OmronConnectionBlocEvent, OmronConnectionState> {
  final AccountDbProvider _accountDbProvider;
  final PendingResultsDbProvider _pendingResultsDbProvider;
  final PairedDevicesDbProvider _pairedDevicesDbProvider;
  final SyncBloc _syncBloc;
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;

  Device? _device;
  late final UserAccount _userAccount;
  late final MeasurementType _measurementType;

  bool get reqModelPairing =>
      _device?.reqPairing == true &&
      (_device?.deviceIdentifier == null || _device?.wasPaired != true);

  OmronConnectionBloc(
    this._accountDbProvider,
    this._pendingResultsDbProvider,
    this._pairedDevicesDbProvider,
    this._syncBloc,
  ) : super(const OmronConnectionState.init()) {
    on<OmronConnectionBlocEvent>((event, emit) async {
      Future<DeviceInfo?> verifyDevice(
        BluetoothDevice blDevice,
        AdvertisementData? advertisementData,
      ) async {
        final deviceInfo = await BtConnectionHelper.requestDeviceInfo(blDevice);
        deviceInfo?.advData = advertisementData;

        final batteryInfo =
            await BtConnectionHelper.requestBatteryInfo(blDevice);

        deviceInfo?.batteryInfo = batteryInfo;

        if (deviceInfo != null) {
          emit(
            OmronConnectionState.verified(
              device: blDevice,
              deviceInfo: deviceInfo,
            ),
          );
          return deviceInfo;
        } else {
          emit(
            OmronConnectionState.notVerified(
              measurementResult: HwMeasurementResult(
                resultState: ResultState.connectionError,
                measurementDt: DateTime.now(),
              ),
            ),
          );
          add(const OmronConnectionBlocEvent.stopSearch());

          return null;
        }
      }

      Future<Device?> measureAndSync(
        BluetoothDevice blDevice,
        DeviceInfo deviceInfo,
      ) async {
        if (reqModelPairing) {
          emit(const OmronConnectionState.pairing());
        } else {
          emit(const OmronConnectionState.syncing());
        }

        final measurementResult = await BtConnectionHelper.requestBPData(
          blDevice,
          !reqModelPairing,
        );

        await Wakelock.disable();

        if (measurementResult.resultState == ResultState.success) {
          final measurementInfo = measurementResult.measurementInfo;

          final supportedDev = Constants.supportedDevices.firstWhere(
            (dev) => deviceInfo.advData!.localName
                .toLowerCase()
                .contains(dev.bluetoothName!.toLowerCase()),
          );

          var devId = blDevice.name;
          if (supportedDev.deviceModelType == DeviceModelType.omronM7) {
            devId = devId.split('_').last;
          }

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
          );

          if (_measurementType == MeasurementType.bloodPressure) {
            measurement = measurement.copyWith(
              bloodPressure: BloodPressureValue(
                systolic: measurementInfo?.systolic,
                diastolic: measurementInfo?.diastolic,
              ),
              heartRate: measurementInfo?.pulseRate,
            );
          } else if (_measurementType == MeasurementType.heartRate) {
            measurement =
                measurement.copyWith(heartRate: measurementInfo?.pulseRate);
          }

          await _pendingResultsDbProvider.save(measurement);
          _syncBloc.add(const SyncEvent.syncResults());
        }

        if (reqModelPairing) {
          emit(
            OmronConnectionState.paired(
              deviceInfo: deviceInfo,
            ),
          );

          //save paired device
          if (measurementResult.resultState != ResultState.connectionError) {
            final pairedDevice = _device!.copyWith(
              deviceIdentifier: deviceInfo.advData?.localName,
              wasPaired: true,
              addedAt: DateTime.now(),
            );

            await _pairedDevicesDbProvider.add(pairedDevice);
            return pairedDevice;
          }
        } else {
          emit(
            OmronConnectionState.synced(
              measurementResult: measurementResult,
              deviceInfo: deviceInfo,
            ),
          );
          await Wakelock.disable();
        }

        return null;
      }

      Future<void> connectToDevice(
        BluetoothDevice device,
        advertisementData,
      ) async {
        emit(const OmronConnectionState.connecting());
        await device.connect(autoConnect: false);

        final BluetoothDeviceState deviceState = await device.state.first;
        if (deviceState == BluetoothDeviceState.connected) {
          emit(const OmronConnectionState.connected());
        } else {
          emit(const OmronConnectionState.disconnected());
          return;
        }

        add(OmronConnectionBlocEvent.verifyDevice(device, advertisementData));
      }

      await event.when(
        init: (userId, measurementType, device) async {
          await Wakelock.enable();

          _device = device;
          _userAccount = _accountDbProvider.get(userId)!;
          _measurementType = measurementType;
          final btState = await _flutterBlue.state.first;

          if (btState == BluetoothState.off) {
            emit(const OmronConnectionState.disabledBt());
          } else {
            emit(const OmronConnectionState.noBtPermissions());
          }

          final hasPermissionsGranted =
              await BtConnectionHelper.hasPermissionsGranted();
          if (!hasPermissionsGranted) {
            emit(const OmronConnectionState.noBtPermissions());
          }

          _startCheckingBtState();
        },
        newBtState: (newBtState) async {
          if (newBtState == BluetoothState.on) {
            add(const OmronConnectionBlocEvent.checkDeviceAvailability());
          } else if (newBtState == BluetoothState.off) {
            emit(const OmronConnectionState.disabledBt());
          } else {
            emit(const OmronConnectionState.noBtPermissions());
          }
        },
        checkDeviceAvailability: () async {
          add(const OmronConnectionBlocEvent.searchDevice());
        },
        searchDevice: () async {
          emit(const OmronConnectionState.searching());
          final foundDevice = await BtConnectionHelper.searchDevice(
            serviceUuid: bloodPressureServiceUuid,
            device: _device!,
          );
          if (foundDevice != null) {
            add(
              OmronConnectionBlocEvent.foundDevice(
                foundDevice.device,
                foundDevice.advertisementData,
              ),
            );
            add(
              OmronConnectionBlocEvent.connectToDevice(
                foundDevice.device,
                foundDevice.advertisementData,
              ),
            );
          }
        },
        stopSearch: () async {
          await Wakelock.disable();
          _flutterBlue.stopScan();
        },
        connectToDevice: (device, advertisementData) async {
          await connectToDevice(device, advertisementData);
        },
        verifyDevice: (device, advertisementData) async {
          final deviceInfo = await verifyDevice(device, advertisementData);

          if (deviceInfo != null) {
            add(OmronConnectionBlocEvent.measureAndSync(device, deviceInfo));
          }
        },
        measureAndSync: (blDevice, deviceInfo) async {
          final pairedDevice = await measureAndSync(blDevice, deviceInfo);

          //if device was about pairing before, then now we are expecting measurement data results,
          if (pairedDevice != null) {
            //updating device containing mac address to do syncing in future (no pairing anymore)
            _device = pairedDevice;
            //straight after pairing process, device should be turned off,
            //then we can start search for device again in metering mode
            await Future.delayed(const Duration(seconds: 5));
            final foundDevice = await BtConnectionHelper.searchDevice(
              serviceUuid: bloodPressureServiceUuid,
              device: _device!,
            );
            if (foundDevice != null) {
              await foundDevice.device.connect(autoConnect: false);
              await measureAndSync(foundDevice.device, deviceInfo);
            }
          }
        },
        foundDevice: (device, advertisementData) async {
          emit(OmronConnectionState.found(device: device));
        },
      );
    });
  }

  void _startCheckingBtState() {
    FlutterBluePlus.instance.state.listen((btState) {
      add(OmronConnectionBlocEvent.newBtState(btState));
    });
  }
}
