// ignore_for_file: non_constant_identifier_names

import 'package:flutter_user/translations/en_lang.dart';
import 'package:flutter_user/translations/es_lang.dart';
import 'package:flutter_user/translations/fr_lang.dart';
import 'package:flutter_user/functions/functions.dart';

/// Maps language codes to their translation maps.
final Map<String, Map<String, dynamic>> _langMaps = {
  'en': en,
  'es': es,
  'fr': fr,
};

/// Safe translation accessor.
/// Usage: t('text_cancel') instead of t('text_cancel')
/// Falls back to English if the key is missing in the chosen language.
/// Returns the key itself if not found anywhere, preventing null crashes.
String t(String key) {
  // Try the current language first
  final currentLang = _langMaps[choosenLanguage];
  if (currentLang != null) {
    final val = currentLang[key];
    if (val != null) return val.toString();
  }

  // Fall back to English
  final enVal = en[key];
  if (enVal != null) return enVal.toString();

  // Last resort: return the key so UI always has something to display
  return key;
}
