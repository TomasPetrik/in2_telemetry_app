import 'package:flutter/cupertino.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
    this.activeColor,
    this.backgroundColor,
  }) : super(key: key);

  final Color? activeColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return const CupertinoActivityIndicator(
      radius: 14,
    );
  }
}
