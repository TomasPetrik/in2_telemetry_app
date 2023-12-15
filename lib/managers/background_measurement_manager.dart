import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/measurement/source_device_info.dart';
import 'package:scalesoft_app/managers/ble_e8x_manager.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/providers/pending_results_dbs_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/services/sync_service.dart';

@singleton
class BackgroundMeasurementManager {
  final SyncService _syncService;
  final AccountDbProvider _accountDbProvider;

  BackgroundMeasurementManager(this._syncService, this._accountDbProvider);

  Future<bool> isBackgroundSynchronizationSetup() async {
    final assignedDevices = _getUsersWithWatches().map((x) => x.value.bluetoothAddress!);
    final associatedDevices = (await getAssociatedMacAddresses()).toSet();

    return associatedDevices.containsAll(assignedDevices);
  }

  Future<void> removeUnassignedDevices() async {
    final assignedDevices = _getUsersWithWatches().map((x) => x.value.bluetoothAddress!).toList();
    final associatedDevices = (await getAssociatedMacAddresses()).toSet();

    final unassignedDevices = associatedDevices.whereNot(assignedDevices.contains);
    await disassociateDevices(unassignedDevices);
  }

  Iterable<MapEntry<UserAccount, Device>> _getUsersWithWatches() {
    final accounts = _accountDbProvider.getAll();
    final accountDevicePairs = accounts
        .expand<MapEntry<UserAccount, Device>>(
          (account) => (account.assignedDevices ?? []).map((device) => MapEntry(account, device)),
        )
        .where((pair) => pair.value.deviceModelType == DeviceModelType.e8x)
        .where((pair) => pair.value.bluetoothAddress != null);

    return accountDevicePairs;
  }

  Future<void> disassociateDevices(Iterable<String> macAddresses) async {
    // TODO: Call native code, delete background service if no associated devices left?
  }

  /// Uses CompanionDeviceManager to associate a device with the specified [macAddress].
  /// Reschedules (or creates) a background service that periodically calls [syncArmbandMeasurements]
  Future<bool> associateDevice(String macAddress) async {
    // TODO: Call native code, create background service

    return true;
  }

  Future<void> syncArmbandMeasurements() async {
    final associatedAddresses = await getAssociatedMacAddresses();

    final accountDevicePairs = _getUsersWithWatches().where(
      (pair) =>
          associatedAddresses.any((address) => address.toLowerCase() == pair.value.bluetoothAddress!.toLowerCase()),
    );

    final results = await Future.wait([
      for (final pair in accountDevicePairs) _getMeasurementsFromDevice(pair.key, pair.value),
    ]);

    final flatResults = results.expand((x) => x);

    await getIt<PendingResultsDbProvider>().saveAll(flatResults);

    // Update devices' lastMeasurementTimes
    for (final pair in accountDevicePairs) {
      _accountDbProvider.save(pair.key);
    }

    await _syncService.syncResults();
  }

  Future<List<String>> getAssociatedMacAddresses() async {
    // TODO: Call native code, get associated devices.
    return [];
  }

  Future<Iterable<Measurement>> _getMeasurementsFromDevice(
    UserAccount account,
    Device device,
  ) async {
    final watchManager = BleE8xManager();

    List<Measurement> results = [];

    final btDevice = BluetoothDevice(
      remoteId: DeviceIdentifier(device.bluetoothAddress!),
    );

    await watchManager.registerNotifications(btDevice);
    await watchManager.setTime(btDevice);
    results.addAll(await watchManager.getBatteryLevel(btDevice));
    results.addAll(await watchManager.getBloodPressureHistory(btDevice));
    results.addAll(await watchManager.getHeartRateHistory(btDevice));
    results.addAll(await watchManager.getOxygenSaturationHistory(btDevice));

    if (device.lastMeasurementTime != null) {
      results = results.where((x) => x.measurementDateTime?.isAfter(device.lastMeasurementTime!) ?? true).toList();
    }

    final lastMeasurementTime = results.map((x) => x.measurementDateTime!).max;
    device.lastMeasurementTime = lastMeasurementTime;

    return results.map(
      (x) => x.copyWith(
        patientMuid: account.user.muid,
        sourceDeviceWithMetadata: SourceDeviceInfo(
          sourceDevice: device,
        ),
      ),
    );
  }
}
