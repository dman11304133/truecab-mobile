// This file assembles the global `languages` map from modular language files.
// To add or edit a language, modify the corresponding file:
//   - en_lang.dart  (English)
//   - es_lang.dart  (Spanish)
//   - fr_lang.dart  (French)

import 'package:flutter_user/translations/en_lang.dart';
import 'package:flutter_user/translations/es_lang.dart';
import 'package:flutter_user/translations/fr_lang.dart';

// Re-export the t() helper so all files importing translation.dart
// automatically get access to it without a second import.
export 'package:flutter_user/translations/translation_helper.dart';

Map<String, dynamic> languages = {
  "en": en,
  "es": es,
  "fr": fr,
};
