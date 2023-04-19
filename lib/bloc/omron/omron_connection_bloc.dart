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
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/utils/helpers/bt_connection_helper.dart';

@injectable
class OmronConnectionBloc
    extends Bloc<OmronConnectionBlocEvent, OmronConnectionState> {
  final PendingResultsDbProvider _pendingResultsDbProvider;
  final PairedDevicesDbProvider _pairedDevicesDbProvider;
  final SyncBloc _syncBloc;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  Device? device;
  String? userId;
  MeasurementType? measurementType;

  bool get reqModelPairing =>
      device!.reqPairing == true && device!.macAddress == null;

  OmronConnectionBloc(
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
          emit(const OmronConnectionState.notVerified());
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

        if (measurementResult.resultState == ResultState.success) {
          final measurementInfo = measurementResult.measurementInfo;

          Measurement? measurement = Measurement(
            patientMuid: userId,
            measurementType: measurementType,
            measurementDateTime: measurementResult.measurementDt,
            sourceDeviceWithMetadata: SourceDeviceInfo(
              sourceDevice: Device(
                deviceIdentifier: blDevice.id.id,
                modelName: deviceInfo.modelNumber,
                deviceManufacturer: deviceInfo.manufacturerName,
              ),
              batteryPercentage: deviceInfo.batteryInfo?.batteryLevel,
            ),
          );

          if (measurementType == MeasurementType.bloodPressure) {
            measurement = measurement.copyWith(
              bloodPressure: BloodPressureValue(
                systolic: measurementInfo?.systolic,
                diastolic: measurementInfo?.diastolic,
              ),
            );
          } else if (measurementType == MeasurementType.heartRate) {
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
            final pairedDevice = device!.copyWith(
              deviceIdentifier: blDevice.id.id,
              macAddress: blDevice.id.id,
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
        }
        return null;
      }

      Future<void> connectToDevice(device, advertisementData) async {
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
          this.device = device;
          this.userId = userId;
          this.measurementType = measurementType;
          final btState = await flutterBlue.state.first;

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
          List<BluetoothDevice> devices = await flutterBlue.connectedDevices;

          if (devices.isNotEmpty) {
            final device = devices[0];
            final BluetoothDeviceState deviceState = await device.state.first;
            if (deviceState == BluetoothDeviceState.connected) {
              add(OmronConnectionBlocEvent.verifyDevice(device, null));
            } else {
              add(OmronConnectionBlocEvent.connectToDevice(device, null));
            }
          } else {
            add(const OmronConnectionBlocEvent.searchDevice());
          }
        },
        searchDevice: () async {
          emit(const OmronConnectionState.searching());
          final foundDevice = await BtConnectionHelper.searchDevice(
            serviceUuid: bloodPressureServiceUuid,
            device: device!,
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
          flutterBlue.stopScan();
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
            device = pairedDevice;
            //straight after pairing process, device should turn off bluetooth,
            //so we can start search for device again after metering
            final foundDevice = await BtConnectionHelper.searchDevice(
              serviceUuid: bloodPressureServiceUuid,
              device: device!,
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
