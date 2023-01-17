import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/ui/screens/debug_device_screen.dart';

class SearchDevicesScreen extends StatelessWidget {
  const SearchDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return const FindDevicesScreen();
          }
          return BluetoothOffScreen(state: state);
        },
      ),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle1
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({super.key});

  Future<bool> checkPermission() async {
    if (!await Permission.location.isGranted) {
      PermissionStatus status = await Permission.location.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }

    if (!await Permission.bluetooth.isGranted) {
      PermissionStatus status = await Permission.bluetooth.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }

    if (!await Permission.bluetoothScan.isGranted) {
      PermissionStatus status = await Permission.bluetoothScan.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    if (!await Permission.bluetoothConnect.isGranted) {
      PermissionStatus status = await Permission.bluetoothConnect.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }

    if (!await Permission.bluetoothAdvertise.isGranted) {
      PermissionStatus status = await Permission.bluetoothAdvertise.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    //checkPermission();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            /*
            StreamBuilder<List<BluetoothDevice>>(
              stream: Stream.periodic(const Duration(seconds: 5)).asyncMap((_) => FlutterBlue.instance.connectedDevices),
              initialData: const [],
              builder: (c, snapshot) => snapshot.data == null
                  ? const Text('No data yet')
                  : Column(
                      children: snapshot.data!
                          .map(
                            (d) => ListTile(
                              title: Text(d.name),
                              subtitle: Text(d.id.toString()),
                              trailing: StreamBuilder<BluetoothDeviceState>(
                                stream: d.state,
                                initialData: BluetoothDeviceState.disconnected,
                                builder: (c, snapshot) {
                                  if (snapshot.data == BluetoothDeviceState.connected) {
                                    return TextButton(
                                      child: const Text('OPEN'),
                                      onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => DeviceScreen(device: d),
                                        ),
                                      ),
                                    );
                                  }
                                  return Text(snapshot.data.toString());
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            */
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              initialData: const [],
              builder: (c, snapshot) => Column(
                children: snapshot.data!
                    .map(
                      (r) => ScanResultTile(
                        result: r,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              r.device.connect();
                              return DebugDeviceScreen(device: r.device);
                            },
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
              child: const Icon(Icons.search),
              onPressed: () => FlutterBlue.instance
                  .startScan(timeout: const Duration(seconds: 4)),
            );
          }
        },
      ),
    );
  }
}
