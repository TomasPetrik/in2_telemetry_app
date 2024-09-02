import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/constants/native_code_constants.dart';
import 'package:scalesoft_app/cubit/background_measurement/background_measurement_cubit.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/device_model_type.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/data/providers/device_db_provider.dart';
import 'package:scalesoft_app/data/providers/measurements_db_provider.dart';
import 'package:scalesoft_app/managers/ble_e8x_manager.dart';
import 'package:scalesoft_app/model/device_model.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/report_service.dart';
import 'package:scalesoft_app/services/sync_service.dart';
import 'package:scalesoft_app/utils/helpers/mac_address_helper.dart';

@singleton
class BackgroundMeasurementManager {
  final SyncService _syncService;
  final BackgroundMeasurementCubit _backgroundMeasurementCubit;
  final ReportService _reportService;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DeviceDbProvider _deviceDbProvider;
  final MeasurementsDbProvider _measurementsDbProvider;
  static const nativeCode =
      MethodChannel(NativeCodeConstants.methodChannelName);

  BackgroundMeasurementManager(
    this._syncService,
    this._backgroundMeasurementCubit,
    this._reportService,
    this._deviceDbProvider,
    this._measurementsDbProvider,
  );

  void configureBackgroundServiceMethodCallHandler() {
    nativeCode.setMethodCallHandler((call) async {
      if (call.method != NativeCodeConstants.bluetoothSyncMethod) {
        debugPrint("Unsupported method called: ${call.method}");
        return Future.error("Unsupported method");
      }

      final devices =
          call.arguments[NativeCodeConstants.macAddressesKey] as List;
      await syncArmbandMeasurements(devices.map((x) => x.toString()));
      return "success";
    });
  }

  Future<bool> isSetupRequired() async {
    if (!Platform.isAndroid) {
      return false;
    }

    final assignedDevices = await _getWatchesMacAddresses();

    if (assignedDevices.isEmpty) {
      return false;
    }

    final associatedDevices = (await getAssociatedMacAddresses()).toSet();

    return !associatedDevices.containsAll(assignedDevices);
  }

  Future<void> updateBackgroundSynchronizationState() async {
    if (!Platform.isAndroid) {
      return;
    }

    final assignedDevices = await _getWatchesMacAddresses();
    final associatedDevices = (await getAssociatedMacAddresses()).toSet();

    debugPrint("assigned devices count: ${assignedDevices.length}");
    debugPrint("associated devices count: ${associatedDevices.length}");

    if (associatedDevices.isEmpty || assignedDevices.isEmpty) {
      _backgroundMeasurementCubit.disabled();
    } else if (associatedDevices.containsAll(assignedDevices)) {
      _backgroundMeasurementCubit.enabled();
    } else {
      _backgroundMeasurementCubit.partial();
    }
  }

  Future<void> activateBackgroundSynchronization() async {
    final assignedDevices = await _getWatchesMacAddresses();

    final result = await associateDevices(assignedDevices);
    if (!result) {
      _backgroundMeasurementCubit.setupError();
    }
  }

  Future<void> deactivateBackgroundSynchronization() async {
    if (!Platform.isAndroid) {
      return;
    }

    final associatedDevices = await getAssociatedMacAddresses();
    await disassociateDevices(associatedDevices);
  }

  Future<void> removeUnassignedDevices() async {
    if (!Platform.isAndroid) {
      return;
    }

    final assignedDevices = (await _getWatchesMacAddresses()).toList();
    final associatedDevices = (await getAssociatedMacAddresses()).toSet();

    final unassignedDevices =
        associatedDevices.whereNot(assignedDevices.contains);

    if (unassignedDevices.isNotEmpty) {
      await disassociateDevices(unassignedDevices);
    }
  }

  Future<Iterable<DeviceModel>> _getWatches() async {
    final devices = await _deviceDbProvider.getAll();

    final watches = devices
        .where((x) => x.prototype.deviceModelType == DeviceModelType.e8x)
        .where((x) => x.bluetoothAddress != null);

    return watches;
  }

  Future<Iterable<String>> _getWatchesMacAddresses() async {
    return (await _getWatches())
        .map((x) => x.bluetoothAddress!)
        .map(MacAddressHelper.normalizeFormat);
  }

  Future<bool> anyUserWatchAssignmentExists() async {
    return (await _getWatches()).isNotEmpty;
  }

  /// Uses CompanionDeviceManager to disassociate devices with the specified [macAddresses].
  /// Removes background service if no associated devices are left.
  Future<bool> disassociateDevices(Iterable<String> macAddresses) async {
    try {
      await nativeCode.invokeMethod(
        NativeCodeConstants.disassociateDevices,
        {NativeCodeConstants.macAddressesKey: macAddresses.toList()},
      );
      return true;
    } on PlatformException catch (e) {
      debugPrint("Disassociate devices: native code invocation failed: $e");
      _reportService.trackEvent(
        severity: LogSeverity.error,
        message: e.toString(),
      );
      return false;
    }
  }

  /// Uses CompanionDeviceManager to associate devices with the specified [macAddresses].
  /// Reschedules (or creates) a background service that periodically calls [syncArmbandMeasurements]
  Future<bool> associateDevices(Iterable<String> macAddresses) async {
    try {
      await nativeCode.invokeMethod(
        NativeCodeConstants.associateDevices,
        {NativeCodeConstants.macAddressesKey: macAddresses.toList()},
      );
      return true;
    } on PlatformException catch (e) {
      debugPrint("Associate devices: native code invocation failed: $e");
      _reportService.trackEvent(
        severity: LogSeverity.error,
        message: e.toString(),
      );
      return false;
    }
  }

  Future<void> syncArmbandMeasurements(
      Iterable<String> associatedAddresses) async {
    final watches = await _getWatches();
    final matchedWatches = watches.where(
      (x) => associatedAddresses.any(
          (address) => MacAddressHelper.compare(address, x.bluetoothAddress)),
    );

    final results = await Future.wait([
      for (final watch in matchedWatches) _getMeasurementsFromDevice(watch),
    ]);

    final flatResults = results.expand((x) => x);

    for (final measurement in flatResults) {
      await _measurementsDbProvider.saveModel(measurement);
    }

    await _syncService.syncResults(fetchMeasurementResults: false);
  }

  Future<Iterable<String>> getAssociatedMacAddresses() async {
    if (!Platform.isAndroid) {
      return [];
    }

    try {
      final addresses = await nativeCode
          .invokeListMethod<String>(NativeCodeConstants.getAssociatedDevices);
      return addresses?.map(MacAddressHelper.normalizeFormat) ?? [];
    } on PlatformException catch (e) {
      debugPrint("Associate devices: native code invocation failed: $e");
      _reportService.trackEvent(
        severity: LogSeverity.error,
        message: e.toString(),
      );
      return [];
    }
  }

  Future<Iterable<MeasurementCreateModel>> _getMeasurementsFromDevice(
    DeviceModel device,
  ) async {
    final watchManager = BleE8xManager(device.prototype.userId, device.id);

    List<MeasurementCreateModel> results = [];

    final btDevice = BluetoothDevice(
      remoteId: DeviceIdentifier(
          MacAddressHelper.normalizeFormat(device.bluetoothAddress!)),
    );

    try {
      await btDevice.connect(timeout: const Duration(seconds: 30));
    } catch (e) {
      await _notificationsPlugin.show(
        1,
        localization.common_app_name,
        localization.watch_synchronization_failed,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'scalesoft_android',
            'scalesoft_android_channel',
            channelDescription: 'scalesoft_android_channel_description',
            color: Color.fromARGB(255, 33, 100, 123),
            icon: "ic_notification_foreground",
          ),
        ),
      );
    }

    await watchManager.registerNotifications(btDevice);
    await watchManager.setTime(btDevice);
    results.addAll(await watchManager.getBatteryLevel(btDevice));
    results.addAll(await watchManager.getBloodPressureHistory(btDevice));
    results.addAll(await watchManager.getHeartRateHistory(btDevice));
    results.addAll(await watchManager.getOxygenSaturationHistory(btDevice));

    if (device.lastMeasurementTime != null) {
      results = results
          .where((x) => x.measuredAt.isAfter(device.lastMeasurementTime!))
          .toList();
    }

    final lastMeasurementTime = results.map((x) => x.measuredAt).max;

    _deviceDbProvider.updateDevice(device.id,
        DevicesCompanion(lastMeasurementTime: Value(lastMeasurementTime)));

    return results;
  }
}
