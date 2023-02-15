import 'package:flutter/material.dart';

class RotatingIcon extends StatefulWidget {
  const RotatingIcon({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  @override
  void initState() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationController.forward();

    _rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rotationController.repeat();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_rotationController),
      child: widget.child,
    );
  }
}
