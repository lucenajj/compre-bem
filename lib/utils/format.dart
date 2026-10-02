import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Inicializa os dados de localização pt-BR (nomes de meses etc).
Future<void> initFormatting() => initializeDateFormatting('pt_BR');

/// Formata valores em reais: R$ 24,90
final brl = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$', decimalDigits: 2);

/// 'YYYY-MM' a partir de um DateTime.
String monthKeyOf(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

/// 'Outubro de 2026' a partir de 'YYYY-MM'.
String monthLabel(String key) {
  final parts = key.split('-');
  final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
  final s = DateFormat('MMMM yyyy', 'pt_BR').format(d);
  return s[0].toUpperCase() + s.substring(1);
}

/// 'out' a partir de 'YYYY-MM'.
String shortMonth(String key) {
  final parts = key.split('-');
  final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
  return DateFormat('MMM', 'pt_BR').format(d).replaceAll('.', '');
}

/// '05/09/2026'.
String fmtDate(DateTime d) => DateFormat('dd/MM/yyyy', 'pt_BR').format(d);
