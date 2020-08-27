import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// TODO : Check if currency formatter work
// Source : https://stackoverflow.com/a/50530099/5527968
class CurrencyInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      print(true);
      return newValue;
    }

    double value = double.parse(newValue.text);

    //final formatter = NumberFormat.simpleCurrency(locale: "fr_FR");
    final formatter = new NumberFormat('###,###', 'fr_FR');

    String newText = formatter.format(value);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}
