// lib/core/utils/currency_formatter.dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦ ',
    decimalDigits: 2,
  );

  static String format(dynamic amount) {
    if (amount == null) return '₦ 0.00';
    final parsed = double.tryParse(amount.toString()) ?? 0.0;
    return _formatter.format(parsed);
  }

  static String formatCompact(dynamic amount) {
    if (amount == null) return '₦ 0';
    final parsed = double.tryParse(amount.toString()) ?? 0.0;
    if (parsed >= 1000000) {
      return '₦ ${(parsed / 1000000).toStringAsFixed(1)}M';
    } else if (parsed >= 1000) {
      return '₦ ${(parsed / 1000).toStringAsFixed(1)}k';
    }
    return _formatter.format(parsed);
  }
}
