import 'package:flutter/material.dart';

class UserItemPainter extends CustomPainter {
  UserItemPainter({
    required this.borderColor,
    required this.userItemType,
  });

  final Color borderColor;
  final UserItemType userItemType;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pathPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Path line;

    switch (userItemType) {
      case UserItemType.top:
        line = _getTopPath(size);
        canvas.drawPath(line, pathPaint);
        break;
      case UserItemType.middle:
        line = _getTopPath(size);
        canvas.drawPath(line, pathPaint);
        final line2 = _getLastPath(size);
        canvas.drawPath(line2, pathPaint);
        break;
      case UserItemType.last:
        line = _getLastPath(size);
        canvas.drawPath(line, pathPaint);
        break;
    }
  }

  Path _getTopPath(Size size) {
    final Path line = Path();
    line.moveTo(0, 0);
    line.lineTo(0, size.height);

    return line;
  }

  Path _getLastPath(Size size) {
    final Path line = Path();
    line.moveTo(0, 0);
    line.lineTo(0, size.height / 2 - size.width);
    line.cubicTo(
      0,
      size.height / 2 - size.width,
      0,
      size.height / 2,
      size.width,
      size.height / 2,
    );

    return line;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum UserItemType { top, middle, last }
