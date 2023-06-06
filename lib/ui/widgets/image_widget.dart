import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as path;

class ImageWidget extends StatelessWidget {
  const ImageWidget(
    this.assetPath, {
    super.key,
  });

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final imageExtension = path.extension(assetPath);
    if (imageExtension.toLowerCase() == ".svg") {
      return SvgPicture.asset(assetPath);
    }

    return Image.asset(assetPath);
  }
}
