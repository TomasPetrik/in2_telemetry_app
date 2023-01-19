import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatelessWidget {
  final Future<void> Function() loadingFunction;
  final VoidCallback onLoaded;

  const SplashScreen({
    super.key,
    required this.loadingFunction,
    required this.onLoaded,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadingFunction().then(((_) => onLoaded())),
      builder: (context, snapshot) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

        return MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Center(
                child: Image.asset(
                  'assets/images/icon.png',
                  height: 64,
                  width: 64,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
