import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scalesoft_app/bloc/warning/warning_bloc.dart';
import 'package:scalesoft_app/bloc/warning/warning_bloc_event.dart';
import 'package:scalesoft_app/bloc/warning/warning_bloc_state.dart';
import 'package:scalesoft_app/l10n/localized_build_context_extension.dart';
import 'package:scalesoft_app/providers/account_db_provider.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/widgets/notification_item.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final warningBloc = getIt<WarningBloc>();
    return BlocBuilder<WarningBloc, WarningBlocState>(
      bloc: warningBloc,
      builder: (context, state) {
        final accountDbProvider = getIt<AccountDbProvider>();
        final isAnySessionExpired = accountDbProvider.isAnyAccountExpired();

        return state.wasResolved == true || isAnySessionExpired == false
            ? const SliverToBoxAdapter(child: SizedBox.shrink())
            : SliverPadding(
                padding: const EdgeInsets.only(
                  left: Dimensions.padding16,
                  right: Dimensions.padding16,
                  top: Dimensions.padding16,
                ),
                sliver: NotificationItem(
                  title: context.locale.notification_widget_info_title,
                  description: context.locale.notification_widget_info_desc,
                  buttonLabel:
                      context.locale.notification_widget_info_understand,
                  icon: Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/icon_dots_horizontal_big.svg',
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadii.radius4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  buttonType: SmallButtonType.none,
                  onTap: () {
                    warningBloc.add(
                      const ResolvedWarningDialogBlocEvent(),
                    );
                  },
                ),
              );
      },
    );
  }
}
