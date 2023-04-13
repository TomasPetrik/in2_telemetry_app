import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/cubit/auth_web/auth_web_cubit.dart';
import 'package:scalesoft_app/cubit/auth_web/auth_web_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';

class AuthWebScreen extends StatelessWidget {
  AuthWebScreen({
    super.key,
    required this.authUri,
    required this.onRedirect,
    required this.onCancelled,
  });

  final Uri authUri;
  final Function(Uri) onRedirect;

  final Function onCancelled;
  final AuthWebCubit cubit = getIt<AuthWebCubit>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onCancelled.call();
        GoRouter.of(context).pop();
        return true;
      },
      child: Material(
        child: Stack(
          children: [
            Positioned.fill(
              child: InAppWebView(
                onLoadStart: (controller, url) {
                  debugPrint('onLoad start');
                },
                onLoadStop: (controller, url) {
                  debugPrint('onLoad stop');
                  cubit.loaded();
                },
                initialUrlRequest: URLRequest(
                  url: WebUri(authUri.toString()),
                ),
                initialSettings: InAppWebViewSettings(
                  clearCache: true,
                  cacheEnabled: false,
                ),
                onReceivedError: (controller, request, error) {
                  if (request.url.uriValue
                      .toString()
                      .startsWith('cz.scalesoft.tlm')) {
                    final authRespUri = request.url.uriValue;

                    onRedirect.call(authRespUri);
                  }
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint(consoleMessage.message);
                },
              ),
            ),
            BlocBuilder<AuthWebCubit, AuthWebState>(
              bloc: cubit,
              builder: ((context, state) {
                final widget = state.when(
                  loaded: SizedBox.shrink,
                  loading: LoadingIndicator.new,
                );

                return Align(alignment: Alignment.center, child: widget);
              }),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  onCancelled.call();
                  GoRouter.of(context).pop();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
