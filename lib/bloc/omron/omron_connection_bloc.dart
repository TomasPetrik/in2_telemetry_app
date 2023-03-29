import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_int_value.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/api/dto/measurement/measurement.dart';
import 'package:scalesoft_app/api/dto/measurement/source_device_info.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_bloc_event.dart';
import 'package:scalesoft_app/bloc/omron/omron_connection_state.dart';
import 'package:scalesoft_app/bloc/sync/sync_bloc.dart';
import 'package:scalesoft_app/bloc/sync/sync_event.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/providers/paired_devices_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/ui/screens/constants.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/utils/helpers/omron_connection_helper.dart';

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
      device!.deviceModel == DeviceModel.omronM7 && device!.macAddress == null;

  OmronConnectionBloc(
    this._pendingResultsDbProvider,
    this._pairedDevicesDbProvider,
    this._syncBloc,
  ) : super(const OmronConnectionState.init()) {
    on<OmronConnectionBlocEvent>((event, emit) async {
      Future<void> verifyDevice(
        BluetoothDevice blDevice,
        AdvertisementData? advertisementData,
      ) async {
        final deviceInfo =
            await OmronConnectionHelper.requestDeviceInfo(blDevice);
        deviceInfo?.advData = advertisementData;
        if (deviceInfo != null) {
          emit(
            OmronConnectionState.verified(
              device: blDevice,
              deviceInfo: deviceInfo,
            ),
          );
        } else {
          emit(const OmronConnectionState.notVerified());
          return;
        }

        final batteryInfo =
            await OmronConnectionHelper.requestBatteryInfo(blDevice);

        deviceInfo.batteryInfo = batteryInfo;

        if (reqModelPairing) {
          emit(const OmronConnectionState.pairing());
        } else {
          emit(const OmronConnectionState.syncing());
        }

        final measurementResult = await OmronConnectionHelper.requestBPData(
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
              batteryPercentage: batteryInfo?.batteryLevel,
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
          //save paired device
          if (measurementResult.resultState != ResultState.connectionError) {
            final supportedDevice = Constants.supportedDevices.firstWhere(
              (suppDevice) => suppDevice.deviceModel == device!.deviceModel,
            );

            await _pairedDevicesDbProvider.add(
              supportedDevice.copyWith(
                macAddress: blDevice.id.id,
                addedAt: DateTime.now(),
              ),
            );
          }

          emit(
            OmronConnectionState.paired(
              measurementResult: measurementResult.copyWith(
                resultState:
                    measurementResult.resultState != ResultState.connectionError
                        ? ResultState.paired
                        : measurementResult.resultState,
              ),
              deviceInfo: deviceInfo,
            ),
          );
        } else {
          emit(
            OmronConnectionState.synced(
              measurementResult: measurementResult,
              deviceInfo: deviceInfo,
            ),
          );
        }
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
          final btState = await FlutterBluePlus.instance.state.first;

          if (btState == BluetoothState.on) {
            emit(const OmronConnectionState.enabledBt());
          } else if (btState == BluetoothState.off) {
            emit(const OmronConnectionState.disabledBt());
          } else {
            emit(const OmronConnectionState.noBtPermissions());
          }

          final hasPermissionsGranted =
              await OmronConnectionHelper.hasPermissionsGranted();
          if (!hasPermissionsGranted) {
            emit(const OmronConnectionState.noBtPermissions());
          }

          _startCheckingBtState();
        },
        newBtState: (newBtState) async {
          if (newBtState == BluetoothState.on) {
            emit(const OmronConnectionState.enabledBt());
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
          final foundDevice = await OmronConnectionHelper.searchDevice(
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
          await verifyDevice(device, advertisementData);
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
