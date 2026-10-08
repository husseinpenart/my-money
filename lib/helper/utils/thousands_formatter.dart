import 'package:flutter/services.dart';
import 'package:money/helper/utils/input_utils.dart';

class ThousandsInputFormatter extends TextInputFormatter {
  /// "1500000" یا "۱۵۰۰۰۰۰" یا "1500000.00" → "1,500,000"
  static String format(String raw) {
    final digits = normalizeDigits(raw)
        .split('.')
        .first
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceFirst(RegExp(r'^0+(?=\d)'), '');
    return digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }

  /// فقط رقم‌ها (برای ارسال به سرور)
  static String digitsOnly(String raw) =>
      normalizeDigits(raw).replaceAll(RegExp(r'[^0-9]'), '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = format(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
