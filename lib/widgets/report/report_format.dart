import 'package:money/feature/model/report/report_models.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/helper/utils/number_helper.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

const List<String> kMonthNames = [
  'فروردین',
  'اردیبهشت',
  'خرداد',
  'تیر',
  'مرداد',
  'شهریور',
  'مهر',
  'آبان',
  'آذر',
  'دی',
  'بهمن',
  'اسفند',
];

String fa(String s) => NumberHelper.toPersianDigits(s);

String money(num v) => '${v < 0 ? '−' : ''}${fa(formatAmount(v))}';

String _trim(double x) => x.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');

String compact(num v) {
  final a = v.abs().toDouble();
  final String s;
  if (a >= 1e9) {
    s = '${_trim(a / 1e9)} میلیارد';
  } else if (a >= 1e6) {
    s = '${_trim(a / 1e6)} میلیون';
  } else if (a >= 1e3) {
    s = '${_trim(a / 1e3)} هزار';
  } else {
    s = a.round().toString();
  }
  return fa(s);
}

String pct(double fraction) => fa('${(fraction * 100).round()}٪');

String jalaliDate(DateTime d) {
  final j = Jalali.fromDateTime(d.toLocal());
  return fa(
    '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}',
  );
}

String jalaliDateTime(DateTime d) {
  final l = d.toLocal();
  final t =
      '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  return '${jalaliDate(d)}  ${fa(t)}';
}

String periodText(ReportData d, ReportPeriod p) {
  if (p == ReportPeriod.all) return 'همه‌ی رکوردها';
  final from = d.from != null ? jalaliDate(d.from!) : '—';
  final to = d.to != null ? jalaliDate(d.to!) : 'امروز';
  return 'از $from تا $to  (${p.label})';
}

String agingLabel(String key) => switch (key) {
  'notDue' => 'سررسید نشده',
  'd1_30' => '۱ تا ۳۰ روز معوق',
  'd31_60' => '۳۱ تا ۶۰ روز معوق',
  'd61_90' => '۶۱ تا ۹۰ روز معوق',
  'd90plus' => 'بیش از ۹۰ روز معوق',
  _ => key,
};

/// متن قابل کپی با همه‌ی مشخصات گزارش
String buildReportText(ReportData d, ReportPeriod p) {
  final s = d.summary;
  final b = d.budget;
  final w = StringBuffer()
    ..writeln('گزارش مالی')
    ..writeln('بازه: ${periodText(d, p)}')
    ..writeln(
      'زمان تولید: ${d.generatedAt != null ? jalaliDateTime(d.generatedAt!) : '—'}',
    )
    ..writeln(
      'تعداد رکورد: ${fa('${s.recordCount}')} | تعداد طرف حساب: ${fa('${s.contactCount}')}',
    )
    ..writeln('────────────')
    ..writeln('بدهی و طلب')
    ..writeln(
      'کل طلب: ${money(s.totalReceivable)} | وصول‌شده: ${money(s.paidReceivable)}',
    )
    ..writeln(
      'کل بدهی: ${money(s.totalDebt)} | پرداخت‌شده: ${money(s.paidDebt)}',
    )
    ..writeln('طلب باقی‌مانده: ${money(s.unpaidReceivable)}')
    ..writeln('بدهی باقی‌مانده: ${money(s.unpaidDebt)}')
    ..writeln('تراز خالص: ${money(s.net)}')
    ..writeln(
      'طلب معوق: ${money(s.overdueReceivable)} | بدهی معوق: ${money(s.overdueDebt)}',
    )
    ..writeln('تعداد رکورد معوق: ${fa('${s.overdueCount}')}')
    ..writeln(
      'سررسید ۳۰ روز آینده: دریافتی ${money(s.dueSoonReceivable)} | پرداختی ${money(s.dueSoonDebt)}',
    );
  if (s.collectionRate != null)
    w.writeln('نرخ وصول طلب: ${pct(s.collectionRate!)}');
  if (s.repaymentRate != null)
    w.writeln('نرخ بازپرداخت بدهی: ${pct(s.repaymentRate!)}');
  if (s.invalidAmountCount > 0) {
    w.writeln(
      'توجه: ${fa('${s.invalidAmountCount}')} رکورد مبلغ نامعتبر داشت و در جمع‌ها نیامده است.',
    );
  }

  if (b.hasProfile && b.cycleCount > 0) {
    w
      ..writeln('────────────')
      ..writeln('حقوق و هزینه (${fa('${b.cycleCount}')} دوره‌ی مالی)')
      ..writeln(
        'درآمد: ${money(b.income)}${b.estimatedCycles > 0 ? ' (شامل ${fa('${b.estimatedCycles}')} دوره‌ی تخمینی)' : ''}',
      )
      ..writeln('هزینه: ${money(b.expense)}')
      ..writeln(
        '${b.saved < 0 ? 'کسری' : 'پس‌انداز'}: ${money(b.saved.abs())}',
      );
    if (b.savingsRate != null)
      w.writeln('نرخ پس‌انداز: ${pct(b.savingsRate!)}');
  }
  return w.toString();
}
