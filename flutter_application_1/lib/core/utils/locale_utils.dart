import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Inicializa datos de locale para [DateFormat] con idioma español.
/// Debe llamarse en `main()` antes de `runApp`.
Future<void> setupAppLocale() async {
  await initializeDateFormatting('es', null);
  Intl.defaultLocale = 'es';
}
