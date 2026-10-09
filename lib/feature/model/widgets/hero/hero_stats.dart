import 'package:money/helper/utils/number_helper.dart';

class HeroStats {
  const HeroStats({
    required this.receivableTotal,
    required this.debtTotal,
    required this.netTotal,
    required this.settledCount,
    required this.inProgressCount,
    required this.unpaidCount,
  });

  final int receivableTotal;
  final int debtTotal;
  final int netTotal;
  final int settledCount;
  final int inProgressCount;
  final int unpaidCount;

  factory HeroStats.fromJson(Map<String, dynamic> j) {
    final rec = _toInt(j['receivableTotal']);
    final debt = _toInt(j['debtTotal']);
    // اگر بک‌اند netTotal جدا فرستاد همان را بگیر، وگرنه خودمان حساب کن
    final netRaw = j['netTotal'];
    final net = netRaw != null ? _toInt(netRaw) : rec - debt;

    return HeroStats(
      receivableTotal: rec,
      debtTotal: debt,
      netTotal: net,
      settledCount: _toInt(j['settledCount']),
      inProgressCount: _toInt(j['inProgressCount']),
      unpaidCount: _toInt(j['unpaidCount']),
    );
  }
}

int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

// ── فرمت‌های مشترک (دقیقاً همان استایل تصویر: فارسی + هزارگان) ──
String _group(int v) {
  final neg = v < 0;
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${neg ? '-' : ''}$b';
}

/// مبلغ با کامای هزارگان و ارقام فارسی؛ اگر داده نرسید '—'
String formatToman(int? v) =>
    v == null ? '—' : NumberHelper.toPersianDigits(_group(v));

/// شمارنده با ارقام فارسی؛ اگر داده نرسید '—'
String formatCount(int? v) =>
    v == null ? '—' : NumberHelper.toPersianDigits(v.toString());
