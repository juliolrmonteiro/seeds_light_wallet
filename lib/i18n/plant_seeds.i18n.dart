import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byLocale('en_us') +
      {
        'es_es': {
          'Plant': 'Plantar',
          'Plant amount': 'Monto a plantar',
          'Available Balance': 'Balance disponible',
          'Planted Balance': 'Balance de plantadas',
          'Plant Seeds': 'Plantar Seeds',
          'Congratulations\nYour seeds were planted successfully!':
              'Felicitacines\nSus Seeds fueron plantadas exitosamente!',
          'Close': 'Cerrar',
          'The value exceeds your balance': 'El valor excede su balance'
        }
      };

  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
}