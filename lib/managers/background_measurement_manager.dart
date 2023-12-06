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

  BackgroundMeasurementManager(this._syncService);

  /// Uses CompanionDeviceManager to associate a device with the specified [macAddress].
  /// Reschedules (or creates) a background service that periodically calls [syncArmbandMeasurements]
  Future<bool> associateDevice(String macAddress) async {
    // TODO: Call native code, create background service
    return true;
  }

  Future<void> syncArmbandMeasurements() async {
    final accounts = getIt<AccountDbProvider>().getAll();

    final associatedAddresses = getAssociatedMacAddresses();

    final accountDevicePairs = accounts
        .expand<MapEntry<UserAccount, Device>>(
          (account) => (account.assignedDevices ?? [])
              .map((device) => MapEntry(account, device)),
        )
        .where((pair) => pair.value.deviceModelType == DeviceModelType.e8x)
        .where((pair) => pair.value.bluetoothAddress != null)
        .where(
          (pair) => associatedAddresses.any(
            (address) =>
                address.toLowerCase() ==
                pair.value.bluetoothAddress!.toLowerCase(),
          ),
        );

    final results = await Future.wait([
      for (final pair in accountDevicePairs) _getMeasurementsFromDevice(pair),
    ]);

    final flatResults = results.expand((x) => x);

    await getIt<PendingResultsDbProvider>().saveAll(flatResults);
    await _syncService.syncResults();
  }

  List<String> getAssociatedMacAddresses() {
    // TODO: Call native code, get associated devices.
    return [];
  }

  Future<Iterable<Measurement>> _getMeasurementsFromDevice(
    MapEntry<UserAccount, Device> accountDevicePair,
  ) async {
    final watchManager = BleE8xManager();

    List<Measurement> results = [];

    final btDevice = BluetoothDevice(
      remoteId: DeviceIdentifier(accountDevicePair.value.bluetoothAddress!),
    );

    await watchManager.registerNotifications(btDevice);
    await watchManager.setTime(btDevice);
    results.addAll(await watchManager.getBatteryLevel(btDevice));
    results.addAll(await watchManager.getBloodPressureHistory(btDevice));
    results.addAll(await watchManager.getHeartRateHistory(btDevice));
    results.addAll(await watchManager.getOxygenSaturationHistory(btDevice));

    return results.map(
      (x) => x.copyWith(
        patientMuid: accountDevicePair.key.user.muid,
        sourceDeviceWithMetadata: SourceDeviceInfo(
          sourceDevice: accountDevicePair.value,
        ),
      ),
    );
  }
}
