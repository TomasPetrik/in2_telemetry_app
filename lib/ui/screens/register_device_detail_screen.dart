import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_event.dart';
import 'package:scalesoft_app/bloc/register_device/register_device_bloc_state.dart';
import 'package:scalesoft_app/model/user_account.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/register_device_success_route.dart';
import 'package:scalesoft_app/ui/screens/mixins/bottom_sheet_mixin.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
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
  final TextEditingController assignedidentifierController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          BlocConsumer<RegisterDeviceBloc, RegisterDeviceBlocState>(
            bloc: registerDeviceBloc,
            listener: (context, state) {
              state.whenOrNull(
                deviceRegistered: () => GoRouter.of(context).replaceNamed(
                  RegisterDeviceSuccessRoute.name,
                  params: {'deviceName': device.visibleName!},
                ),
                deviceAlreadyRegistered: (key) =>
                    showDevAlreadyRegistered(context, device.deviceIdentifier!),
                failedRegistration: (key) => showServerError(context),
              );
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: Paddings.horizontal16,
                  child: Form(
                    key: registerDevFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(
                          MediaQuery.of(context).viewPadding.top +
                              Dimensions.appBarHeight,
                        ),
                        const Gap(Dimensions.padding16),
                        Text(
                          localization.register_device_detail_screen_device,
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
                          initialValue: device.visibleName,
                          style: ScaleTextStyles.text.apply(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        const Gap(Dimensions.padding24),
                        Text(
                          localization
                              .register_device_detail_screen_identificator,
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
                          initialValue: device.deviceIdentifier,
                          style: ScaleTextStyles.text.apply(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        const Gap(Dimensions.padding24),
                        Text(
                          localization
                              .register_device_detail_screen_assigned_id,
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
                          controller: assignedidentifierController,
                          hintText: localization
                              .register_device_detail_screen_assigned_id_hint,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localization
                                  .register_device_detail_screen_not_filled_field;
                            }
                            return null;
                          },
                        ),
                        Gaps.gap24,
                        HighlightedElevatedButton(
                          label: localization
                              .register_device_detail_screen_button_register,
                          buttonType: state !=
                                  const RegisterDeviceBlocState.registering()
                              ? ButtonType.primary
                              : ButtonType.secondary,
                          onPressed: state !=
                                  const RegisterDeviceBlocState.registering()
                              ? () async {
                                  if (registerDevFormKey.currentState
                                          ?.validate() ==
                                      true) {
                                    registerDeviceBloc.add(
                                      RegisterDeviceBlocEvent.registerDevice(
                                        userAccount,
                                        device,
                                        assignedidentifierController.text,
                                      ),
                                    );
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScaleAppBar(
              title: localization.register_device_detail_screen_title,
              showClose: true,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
