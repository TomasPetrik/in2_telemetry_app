import 'package:flutter/material.dart';

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
        return MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Center(
                child: Image.asset(
                  'assets/images/app_icon_64.png',
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
