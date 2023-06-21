import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalesoft_app/cubit/auth_web/auth_web_cubit.dart';
import 'package:scalesoft_app/cubit/auth_web/auth_web_state.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/widgets/loading_indicator.dart';
import 'package:scalesoft_app/utils/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthWebScreen extends StatelessWidget {
  AuthWebScreen({
    super.key,
    required this.authUri,
    required this.onRedirect,
    required this.openEGoverment,
    required this.onCancelled,
    required this.onLoadingError,
  });

  final Uri authUri;
  final Function(Uri) onRedirect;
  final Function(Uri) openEGoverment;
  final Function onCancelled;
  final Function onLoadingError;
  final AuthWebCubit cubit = getIt<AuthWebCubit>();

  final WebViewController controller = WebViewController();
  final WebViewCookieManager cookieManager = WebViewCookieManager();

  @override
  Widget build(BuildContext context) {
    cookieManager.clearCookies().then(
      (value) {
        controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar.
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {
                cubit.loaded();
              },
              onWebResourceError: (WebResourceError error) {
                if (error.errorCode == -1009) {
                  onLoadingError();
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
              onUrlChange: (UrlChange change) {
                if (change.url != null) {
                  final authRespUri = Uri.parse(change.url!);
                  final authority = authRespUri.authority;
                  final scheme = authRespUri.scheme;
                  final queryParameters = authRespUri.queryParameters;
                  if (authority.startsWith('cz.scalesoft.tlm') ||
                      scheme.startsWith('cz.scalesoft.tlm')) {
                    if (queryParameters.containsKey('code')) {
                      onRedirect.call(authRespUri);
                    } else {
                      onCancelled();
                    }
                  } else if (scheme == EGoverement.scheme) {
                    openEGoverment.call(authRespUri);
                  }
                }
              },
            ),
          )
          ..loadRequest(authUri);
      },
    );

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              WebViewWidget(
                controller: controller,
                gestureRecognizers: {}..add(
                    const Factory<DragGestureRecognizer>(
                      VerticalDragGestureRecognizer.new,
                    ),
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
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
