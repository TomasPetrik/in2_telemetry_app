import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';

class PermissionGrantWidget extends StatefulWidget {
  final Permission permission;
  final bool isOptional;
  final Function(PermissionStatus) onStatusChanged;

  const PermissionGrantWidget({
    super.key,
    required this.permission,
    required this.onStatusChanged,
    this.isOptional = false,
  });

  @override
  State<StatefulWidget> createState() => _PermissionGrantState();
}

class _PermissionGrantState extends State<PermissionGrantWidget>
    with BottomSheetMixin {
  late Permission _permission;
  PermissionStatus _permissionStatus = PermissionStatus.granted;

  @override
  void initState() {
    super.initState();
    _permission = widget.permission;
    _getPermissionStatus();
  }

  void _getPermissionStatus() async {
    final status = await _permission.status;
    widget.onStatusChanged(status);
    setState(() => _permissionStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => requestPermission(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _permissionStatus == PermissionStatus.granted
                ? SvgPicture.asset(
                    'assets/icons/icon_circle_check_big.svg',
                    color: Theme.of(context).colorScheme.primary,
                    height: 50,
                    key: const Key("Check"),
                  )
                : SvgPicture.asset(
                    'assets/icons/icon_circle.svg',
                    color: Theme.of(context).colorScheme.secondary,
                    key: const Key("Circle"),
                    height: 50,
                  ),
          ),
          Gaps.gap16,
          Expanded(
            child: Text(
              localization.permission_names(_permission),
              softWrap: true,
              style: ScaleTextStyles.text.apply(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/icon_circle_information.svg',
              color: Theme.of(context).hintColor,
              height: 30,
              key: const Key("Check"),
            ),
            onPressed: showPermissionReason,
          ),
        ],
      ),
    );
  }

  void showPermissionReason() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(localization.permission_explanations(_permission)),
          showCloseIcon: true,
        ),
      );
  }

  Future<void> requestPermission(BuildContext context) async {
    final status = await _permission.request();
    if (status != PermissionStatus.granted &&
        _permission == Permission.notification) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showNotificationsSettings(context: context)
            .then((openNotificationSettings) async {
          if (openNotificationSettings == true) {
            await AppSettings.openAppSettings(
              type: AppSettingsType.notification,
            );
          }
        });
      });
    }

    setState(() {
      debugPrint("Permission $_permission status: $status");
      _permissionStatus = status;
      widget.onStatusChanged(status);
    });
  }
}
