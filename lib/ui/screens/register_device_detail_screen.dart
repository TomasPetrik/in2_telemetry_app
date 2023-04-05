import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_event.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/register_device_success_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/widgets/highlighted_elevated_button.dart';
import 'package:scalesoft_app/ui/widgets/scale_app_bar.dart';
import 'package:scalesoft_app/ui/widgets/scale_text_form_field.dart';

final registerDevFormKey = GlobalKey<FormState>();
final List<GlobalKey<FormState>> registerDevGlobalKeys = [
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
];

class RegisterDeviceDetailScreen extends StatelessWidget with BottomSheetMixin {
  RegisterDeviceDetailScreen({
    super.key,
    required this.userAccount,
    required this.device,
  });

  final UserAccount userAccount;
  final Device device;
  final RegisterDeviceBloc registerDeviceBloc = getIt<RegisterDeviceBloc>();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          BlocListener<RegisterDeviceBloc, RegisterDeviceBlocState>(
            bloc: registerDeviceBloc,
            listener: (context, state) {
              state.whenOrNull(
                deviceRegistered: () => GoRouter.of(context).replaceNamed(
                  RegisterDeviceSuccessRoute.name,
                  params: {'deviceName': device.modelName!},
                ),
                deviceAlreadyRegistered: (key) =>
                    showDevAlreadyRegistered(context, device.macAddress!),
                failedRegistration: (key) => showServerError(context),
              );
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: Paddings.horizontal16,
                child: Form(
                  key: registerDevFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(
                        MediaQuery.of(context).viewPadding.top +
                            Constants.appBarHeight,
                      ),
                      const Gap(Dimensions.padding16),
                      Text(
                        context.locale.register_device_detail_screen_device,
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.48),
                        ),
                      ),
                      const Gap(Dimensions.padding8),
                      TextFormField(
                        enabled: false,
                        initialValue: device.modelName,
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const Gap(Dimensions.padding24),
                      Text(
                        context
                            .locale.register_device_detail_screen_mac_address,
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.48),
                        ),
                      ),
                      const Gap(Dimensions.padding8),
                      TextFormField(
                        enabled: false,
                        initialValue: device.macAddress,
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const Gap(Dimensions.padding24),
                      Text(
                        context.locale.register_device_detail_screen_label,
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.48),
                        ),
                      ),
                      const Gap(Dimensions.padding8),
                      ScaleTextFormField(
                        textFormKey: registerDevGlobalKeys[0],
                        hintText: context
                            .locale.register_device_detail_screen_label_hint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.locale
                                .register_device_detail_screen_not_filled_field;
                          }
                          return null;
                        },
                      ),
                      const Gap(Dimensions.padding24),
                      Text(
                        context
                            .locale.register_device_detail_screen_identificator,
                        style: ScaleTextStyles.text.apply(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.48),
                        ),
                      ),
                      const Gap(Dimensions.padding8),
                      ScaleTextFormField(
                        textFormKey: registerDevGlobalKeys[1],
                        hintText: context.locale
                            .register_device_detail_screen_identificator_hint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.locale
                                .register_device_detail_screen_not_filled_field;
                          }
                          return null;
                        },
                      ),
                      Gaps.gap24,
                      HighlightedElevatedButton(
                        label: context.locale
                            .register_device_detail_screen_button_register,
                        buttonType: ButtonType.primary,
                        onPressed: () async {
                          if (registerDevFormKey.currentState?.validate() ==
                              true) {
                            registerDeviceBloc.add(
                              RegisterDeviceBlocEvent.registerDevice(
                                userAccount,
                                device,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScaleAppBar(
              title: context.locale.register_device_detail_screen_title,
              showClose: true,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
