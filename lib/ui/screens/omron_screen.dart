import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/ui/screens/bluetooth_off_screen.dart';
import 'package:scalesoft_app/ui/screens/find_omron_device_screen.dart';

class OmronScreen extends StatelessWidget {
  const OmronScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Omron')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<BluetoothState>(
              stream: FlutterBluePlus.instance.state,
              initialData: BluetoothState.unknown,
              builder: (c, snapshot) {
                final state = snapshot.data;
                if (state == BluetoothState.on) {
                  return const FindOmronDeviceScreen();
                }
                return BluetoothOffScreen(state: state);
              },
            ),
          ),
        ],
      ),
    );
  }
}
