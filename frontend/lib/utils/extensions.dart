import 'package:intl/intl.dart';

extension NumberFormatting on double {
  String toLocaleString() {
    return NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
      locale: 'en_IN',
    ).format(this);
  }
}
