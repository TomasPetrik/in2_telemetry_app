import 'dart:ui';

import 'package:scalesoft_app/model/local_locale.dart';

extension LocaleExtension on Locale {
  LocalLocale toLocal() {
    return LocalLocale(languageCode: languageCode);
  }
}
