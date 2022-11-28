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
import 'package:scalesoft_app/ui/screens/select_device_screen.dart';
import 'package:scalesoft_app/ui/themes/scalesoft_colors.dart';

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
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: RefreshIndicator(
              color: ScaleColors.mainText2,
              backgroundColor: ScaleColors.dark20,
              edgeOffset: MediaQuery.of(context).viewPadding.top + 50,
              onRefresh: () async => {},
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverGap(MediaQuery.of(context).viewPadding.top + 50 + 6),
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
                    color: ScaleColors.blurDark1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top + 6),
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 56,
                                ),
                                Expanded(
                                  child: Text(
                                    widget.userInfo.currentUser.fullName,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                BlocConsumer<AuthBloc, AuthState>(
                                  bloc: getIt<AuthBloc>(),
                                  listener: (context, state) {
                                    if (state is LogoutSuccess) {
                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                        AuthScreen.routeName,
                                        (route) => false,
                                      );
                                    }
                                  },
                                  builder: (context, state) {
                                    return SizedBox(
                                      width: 56,
                                      child: IconButton(
                                        onPressed: () {
                                          getIt<AuthBloc>().add(const LogoutUser());
                                        },
                                        icon: const Icon(
                                          Icons.logout,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
