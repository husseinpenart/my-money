import 'package:flutter/material.dart';
import 'package:money/widgets/report/report_format.dart';

enum CurrencyUnit { toman, rial }

/// واحد پول را در سراسر subtree هیرو پخش می‌کند.
/// بچه‌ها با CurrencyScope.of(context) ضریب/برچسب/فرمت را می‌گیرند
/// و همین‌طور const می‌مانند.
class CurrencyScope extends InheritedWidget {
  const CurrencyScope({
    super.key,
    required this.unit,
    required this.toggle,
    required super.child,
  });

  final CurrencyUnit unit;
  final VoidCallback toggle;

  static CurrencyScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CurrencyScope>()!;

  double get factor => unit == CurrencyUnit.rial ? 10 : 1;
  String get label => unit == CurrencyUnit.rial ? 'ریال' : 'تومان';
  bool get isRial => unit == CurrencyUnit.rial;

  /// مقدار خام (تومان) → رشته‌ی فرمت‌شده با واحد فعلی
  String format(num raw) => money(raw * factor);

  @override
  bool updateShouldNotify(CurrencyScope old) => old.unit != unit;
}
