/// ارقام فارسی/عربی → انگلیسی
String normalizeDigits(String input) {
  final sb = StringBuffer();
  for (final ch in input.runes) {
    if (ch >= 0x06F0 && ch <= 0x06F9) {
      sb.writeCharCode(0x30 + (ch - 0x06F0));
    } else if (ch >= 0x0660 && ch <= 0x0669) {
      sb.writeCharCode(0x30 + (ch - 0x0660));
    } else {
      sb.writeCharCode(ch);
    }
  }
  return sb.toString();
}

/// +98912... / 0098912... / 912... → 0912...  و حذف فاصله و خط‌تیره
String normalizePhone(String raw) {
  var s = normalizeDigits(raw).replaceAll(RegExp(r'[^\d+]'), '');
  if (s.startsWith('+98')) {
    s = '0${s.substring(3)}';
  } else if (s.startsWith('0098')) {
    s = '0${s.substring(4)}';
  } else if (s.startsWith('98') && s.length == 12) {
    s = '0${s.substring(2)}';
  } else if (s.length == 10 && s.startsWith('9')) {
    s = '0$s';
  }
  return s.replaceAll('+', '');
}

bool isValidPhone(String normalized) =>
    RegExp(r'^\d{10,15}$').hasMatch(normalized);

/// مبلغ رشته‌ای ("1,500,000" یا "۱۵۰۰۰۰۰") → عدد
double? parseAmount(String raw) {
  final s = normalizeDigits(raw).replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(s);
}

String formatAmount(num v) => v.round().abs().toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);

/// اگر رشته عددی بود با جداکننده، وگرنه همان رشته
String amountText(String raw) {
  final v = parseAmount(raw);
  return v == null ? raw : formatAmount(v);
}
