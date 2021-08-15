import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byLocale('en_us') +
      {
        'es_es': {
          'Search...': 'Búsqueda...',
          "No users found.": 'No se encontraron usuarios.',
          "Copied": 'Copiado',
          "Oops, Something Went Wrong": 'Ups! Algo salió mal',
        }
      };

  String get i18n => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);
}