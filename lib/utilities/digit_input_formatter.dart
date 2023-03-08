import 'package:flutter/services.dart';


//for account number digit input limiter
class DigitInputFormatter extends TextInputFormatter {
  final int _maxLength;

  DigitInputFormatter(this._maxLength);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newString = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (newString.length > _maxLength) {
      newString = newString.substring(0, _maxLength);
    }
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
