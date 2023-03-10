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
  DeviceModel? reqModelPairing;
  String? userId;
  MeasurementType? measurementType;

  OmronConnectionBloc(
    this._pendingResultsDbProvider,
    this._pairedDevicesDbProvider,
    this._syncBloc,
  ) : super(const OmronConnectionState.init()) {
    on<OmronConnectionBlocEvent>((event, emit) async {
      Future<void> verifyDevice(BluetoothDevice device) async {
        final deviceInfo =
            await OmronConnectionHelper.requestDeviceInfo(device);
        if (deviceInfo != null) {
          emit(
            OmronConnectionState.verified(
              device: device,
              deviceInfo: deviceInfo,
            ),
          );
        } else {
          emit(const OmronConnectionState.notVerified());
          return;
        }

        final batteryInfo =
            await OmronConnectionHelper.requestBatteryInfo(device);

        if (reqModelPairing != null) {
          emit(const OmronConnectionState.pairing());
        } else {
          emit(const OmronConnectionState.syncing());
        }

        final measurementResult = await OmronConnectionHelper.requestBPData(
          device,
          reqModelPairing == null,
        );

        if (measurementResult.resultState == ResultState.success) {
          final measurementInfo = measurementResult.measurementInfo;

          Measurement? measurement = Measurement(
            patientMuid: userId,
            measurementType: measurementType,
            measurementDateTime: measurementResult.measurementDt,
            sourceDeviceWithMetadata: SourceDeviceInfo(
              sourceDevice: Device(
                deviceIdentifier: device.id.id,
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

        if (reqModelPairing != null) {
          //save paired device
          if (measurementResult.resultState != ResultState.connectionError) {
            final supportedDevice = Constants.supportedDevices.firstWhere(
              (device) => device.deviceModel == reqModelPairing,
            );

            await _pairedDevicesDbProvider
                .add(supportedDevice.copyWith(macAddress: device.id.id));
          }

          emit(
            OmronConnectionState.paired(
              measurementResult: measurementResult.copyWith(
                resultState:
                    measurementResult.resultState != ResultState.connectionError
                        ? ResultState.paired
                        : measurementResult.resultState,
              ),
            ),
          );
        } else {
          emit(
            OmronConnectionState.synced(
              measurementResult: measurementResult,
            ),
          );
        }
      }

      Future<void> connectToDevice(BluetoothDevice device) async {
        emit(const OmronConnectionState.connecting());
        await device.connect(autoConnect: false);

        final BluetoothDeviceState deviceState = await device.state.first;
        if (deviceState == BluetoothDeviceState.connected) {
          emit(const OmronConnectionState.connected());
        } else {
          emit(const OmronConnectionState.disconnected());
          return;
        }

        add(OmronConnectionBlocEvent.verifyDevice(device));
      }

      await event.when(
        init: (userId, measurementType, reqModelPairing) async {
          this.reqModelPairing = reqModelPairing;
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
              add(OmronConnectionBlocEvent.verifyDevice(device));
            } else {
              add(OmronConnectionBlocEvent.connectToDevice(device));
            }
          } else {
            add(const OmronConnectionBlocEvent.searchDevice());
          }
        },
        searchDevice: () async {
          emit(const OmronConnectionState.searching());
          final foundDevice = await OmronConnectionHelper.searchDevice(
            serviceUuid: bloodPressureServiceUuid,
          );
          if (foundDevice != null) {
            add(OmronConnectionBlocEvent.foundDevice(foundDevice));
            add(OmronConnectionBlocEvent.connectToDevice(foundDevice));
          }
        },
        stopSearch: () async {
          flutterBlue.stopScan();
        },
        connectToDevice: (device) async {
          await connectToDevice(device);
        },
        verifyDevice: (device) async {
          await verifyDevice(device);
        },
        foundDevice: (BluetoothDevice device) async {
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
