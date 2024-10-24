import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:scalesoft_app/model/device_instruction_model.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class ConnectionLevel extends StatelessWidget {
  const ConnectionLevel({
    super.key,
    required this.label,
    this.deviceInstruction,
    required this.iconPath,
    required this.isDone,
    required this.completedIndex,
    required this.index,
  });

  final String label;
  final DeviceInstructionModel? deviceInstruction;
  final String iconPath;
  final bool isDone;
  final int completedIndex;
  final int index;


Widget getLottieOrImage(String base64String) {

  final decodedBytes = base64Decode(base64String);
  Widget? lottieWidget = getLottieWidget(decodedBytes);
  if (lottieWidget != null) {
    return lottieWidget;
  }

  Widget? imageWidget = getImageWidget(decodedBytes);
  if (imageWidget != null) {
    return imageWidget;
  }

  debugPrint("Invalid Image or Lottie Data");
  return const SizedBox();
}

Widget? getLottieWidget(Uint8List lottieImage) {
  try  {
    final decodedString = utf8.decode(lottieImage);
    
    if (isValidJson(decodedString)) {
      return LottieBuilder.memory(
        lottieImage,
        width: 300,
        height: 300,
      );
    }
  } catch (e) {
    return null;
  }
  return null;
}

bool isValidJson(String jsonString) {
  try {
    jsonDecode(jsonString);
    return true;
  } catch (e) {
    return false;
  }
}

Widget? getImageWidget(Uint8List image) {
  try {
    return Image.memory(
      image,
      fit: BoxFit.contain,
      width: 300,
      height: 300,
    );
  } catch (e) {
    return null;
  }
}


@override
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
    padding: const EdgeInsets.all(10),
    child: 
      Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconPath,
                color: isDone
                    ? Theme.of(context).colorScheme.onTertiary
                    : Theme.of(context).colorScheme.tertiary,
              ),
              Gaps.gap16,
              Expanded(
                child: Text(
                  label,
                  style: ScaleTextStyles.textAccent.apply(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            child: Html(
            data: deviceInstruction?.instructionText ?? "",
              style: {
              "p": Style(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              },
            ),
          ),
          if (deviceInstruction?.image != null && deviceInstruction!.image!.isNotEmpty) 
            getLottieOrImage(deviceInstruction!.image!),

        ],
    ),
  );
}
}
