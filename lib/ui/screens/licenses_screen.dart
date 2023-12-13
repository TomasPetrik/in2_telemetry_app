import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scalesoft_app/oss_licenses.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';
import 'package:scalesoft_app/ui/routers/routes/license_detail_route.dart';
import 'package:scalesoft_app/ui/themes/ui_constants.dart';
import 'package:scalesoft_app/ui/widgets/blurred_scale_app_bart.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  static Future<List<Package>> loadLicenses() async {
    final lm = <String, List<String>>{};
    await for (final l in LicenseRegistry.licenses) {
      for (final p in l.packages) {
        final lp = lm.putIfAbsent(p, () => []);
        lp.addAll(l.paragraphs.map((p) => p.text));
      }
    }
    final licenses = ossLicenses.toList();
    for (final key in lm.keys) {
      licenses.add(
        Package(
          name: key,
          description: '',
          authors: [],
          version: '',
          license: lm[key]!.join('\n\n'),
          isMarkdown: false,
          isSdk: false,
          isDirectDependency: false,
        ),
      );
    }
    return licenses..sort((a, b) => a.name.compareTo(b.name));
  }

  static final _licenses = loadLicenses();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<List<Package>>(
              future: _licenses,
              initialData: const [],
              builder: (context, snapshot) {
                return ListView.separated(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top +
                        Dimensions.appBarHeight,
                  ),
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final package = snapshot.data![index];
                    return ListTile(
                      title: Text('${package.name} ${package.version}'),
                      subtitle: package.description.isNotEmpty
                          ? Text(package.description)
                          : null,
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        GoRouter.of(context).pushNamed(
                          LicenseDetailRoute.name,
                          extra: package,
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredScaleAppBar(
              title: localization.licenses_screen_title,
              showClose: true,
              onBackTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
