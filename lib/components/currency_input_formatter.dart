import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats a digits-only input as a thousands-separated number.
///
/// Falls back to the unformatted input whenever the text cannot be parsed
/// (e.g. pasted or partially edited values) instead of throwing.
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('###,###', 'fr_FR');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final value = double.tryParse(newValue.text);
    if (value == null) {
      return newValue;
    }

    final newText = _formatter.format(value);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
