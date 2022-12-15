import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:scalesoft_app/api/dto/user_info.dart';
import 'package:scalesoft_app/bloc/auth/auth_bloc.dart';
import 'package:scalesoft_app/bloc/auth/auth_event.dart';
import 'package:scalesoft_app/bloc/auth/auth_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/screens/auth_screen.dart';
import 'package:scalesoft_app/ui/screens/configuration_screen.dart';
import 'package:scalesoft_app/ui/screens/select_device_screen.dart';
import 'package:scalesoft_app/ui/themes/constants.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors_light.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_text_styles.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    Key? key,
    required this.userInfo,
  }) : super(key: key);

  static const routeName = '/dashboard';
  final UserInfo userInfo;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthBloc authBloc = getIt<AuthBloc>();

  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: RefreshIndicator(
              color: ScaleColorsLight.content100,
              backgroundColor: ScaleColorsLight.content20,
              edgeOffset: MediaQuery.of(context).viewPadding.top + 56,
              onRefresh: () async => {},
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverGap(MediaQuery.of(context).viewPadding.top + 56 + Dimensions.padding16 + Dimensions.padding16),
                  SliverToBoxAdapter(
                    child: Card(
                      child: Container(
                        color: Colors.amber,
                        height: 300,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Card(
                      child: Container(
                        color: Colors.red,
                        height: 300,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Card(
                      child: Container(
                        color: Colors.purple,
                        height: 300,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          SelectDeviceScreen.routeName,
                        );
                      },
                      child: const Text('Measure'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: ScaleColorsLight.paperTransparent,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).viewPadding.top + Dimensions.padding16,
                        bottom: Dimensions.padding16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BlocListener<AuthBloc, AuthState>(
                                  bloc: authBloc,
                                  listener: (context, state) {
                                    state.whenOrNull(
                                      logoutSuccess: () {
                                        Navigator.of(context).pushNamedAndRemoveUntil(
                                          AuthScreen.routeName,
                                          (route) => false,
                                        );
                                      },
                                    );
                                  },
                                  child: SizedBox(
                                    width: 56,
                                    child: IconButton(
                                      onPressed: () {
                                        authBloc.add(const LogoutUser());
                                      },
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.local_hospital_outlined,
                                        color: ScaleColorsLight.content100,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    style: ScaleTextStyles.textAccent.apply(color: ScaleColorsLight.content100),
                                    widget.userInfo.currentUser.fullName,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 56,
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        ConfigurationScreen.routeName,
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.settings,
                                      color: ScaleColorsLight.content100,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gaps.gap6,
                          Text(
                            style: ScaleTextStyles.label.apply(color: ScaleColorsLight.content80),
                            widget.userInfo.currentUser.fullName,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
