import 'dart:async';
import 'package:money/core/alerts/alert_models.dart';
import 'package:money/core/alerts/device_alerts.dart';
import 'package:money/core/cache/contact_cache.dart';
import 'package:money/core/storage/app_storage.dart';
import 'package:money/feature/model/notification/notification_models.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/widgets/report/report_format.dart';

/// قوانین:
/// ۱) هر روز حداکثر یک «خلاصه‌ی سررسید» فوری.
/// ۲) هر هشدار بودجه فقط یک بار (بر اساس key).
/// ۳) اندروید: اعلان‌های زمان‌بندی‌شده‌ی ساعت ۹ صبح برای هر سررسید.
class AlertCoordinator {
  AlertCoordinator(this._cache, this._s);

  final ContactCache _cache;
  final AppStorage _s;

  static const _kEnabled = 'alerts_enabled';
  static const _kDay = 'alerts_day';
  static const _kSeen = 'alerts_seen';

  NotificationSummary? _last;
  Timer? _timer;

  bool get enabled => _s.getString(_kEnabled) == '1';
  bool get supportsSchedule => DeviceAlerts.supportsSchedule;

  /// باید با کلیک کاربر صدا زده شود (مرورگر در غیر این صورت اجازه نمی‌دهد)
  Future<bool> enable() async {
    final ok = await DeviceAlerts.requestPermission();
    await _s.setString(_kEnabled, ok ? '1' : '0');
    if (ok) {
      final s = _last;
      if (s != null) await _showFresh(s);
      await reschedule();
    }
    return ok;
  }

  Future<void> disable() async {
    await _s.setString(_kEnabled, '0');
    await DeviceAlerts.cancelAll();
  }

  /// با تغییر داده‌های محلی، زمان‌بندی دوباره ساخته می‌شود
  void attach() => _cache.addListener(_soon);

  void _soon() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), reschedule);
  }

  Future<void> clear() async {
    _timer?.cancel();
    _last = null;
    await DeviceAlerts.cancelAll();
    await _s.remove(_kEnabled);
    await _s.remove(_kDay);
    await _s.remove(_kSeen);
  }

  // ───────────── فوری ─────────────
  Future<void> onSummary(NotificationSummary s) async {
    _last = s;
    if (!enabled) return;
    await _showFresh(s);
    await reschedule();
  }

  Future<void> _showFresh(NotificationSummary s) async {
    final now = DateTime.now();
    final day =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    if (_s.getString(_kDay) != day && (s.overdue + s.today) > 0) {
      final parts = [
        if (s.overdue > 0) '${fa('${s.overdue}')} مورد معوق',
        if (s.today > 0) '${fa('${s.today}')} سررسید امروز',
      ];
      await DeviceAlerts.show(
        1,
        'یادآوری سررسیدها',
        parts.join(' و '),
        payload: 'open',
      );
      await _s.setString(_kDay, day);
    }

    final seen = (_s.getStringList(_kSeen) ?? const <String>[]).toSet();
    var changed = false;
    for (final a in s.alerts) {
      if (seen.contains(a.key)) continue;
      await DeviceAlerts.show(
        a.key.hashCode & 0x3fffffff,
        a.title,
        a.message,
        payload: 'open',
      );
      seen.add(a.key);
      changed = true;
    }
    if (changed) {
      final list = seen.toList();
      await _s.setStringList(
        _kSeen,
        list.length > 300 ? list.sublist(list.length - 300) : list,
      );
    }
  }

  // ───────────── زمان‌بندی (اندروید) ─────────────
  static DateTime _date(DateTime d) {
    final u = d.toUtc(); // تاریخ‌ها ساعت ۱۲ UTC ذخیره می‌شوند
    return DateTime(u.year, u.month, u.day);
  }

  static DateTime _at9(DateTime d) => DateTime(d.year, d.month, d.day, 9);

  Future<void> reschedule() async {
    if (!enabled || !DeviceAlerts.supportsSchedule) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = <ScheduledAlert>[];

    final open = _cache.allDebts
        .where((d) => !d.payStatus && d.endedDate != null)
        .toList();

    String amount(SearchDebt d) {
      final v = parseAmount(d.wholePrice);
      return v == null ? d.wholePrice : money(v);
    }

    for (final d in open) {
      final due = _date(d.endedDate!);
      final who = d.contactName;
      final a = amount(d);
      final tag = d.payId;

      final before = _at9(due.subtract(const Duration(days: 1)));
      if (before.isAfter(now)) {
        out.add(
          ScheduledAlert(
            ('$tag#1').hashCode & 0x3fffffff,
            before,
            d.isDebt ? 'بدهی‌ات فردا سررسید می‌شود' : 'طلبت فردا سررسید می‌شود',
            d.isDebt ? 'پرداخت $a به $who' : 'دریافت $a از $who',
            payload: 'debt:${d.payId}',
          ),
        );
      }
      final onDay = _at9(due);
      if (onDay.isAfter(now)) {
        out.add(
          ScheduledAlert(
            ('$tag#0').hashCode & 0x3fffffff,
            onDay,
            d.isDebt ? 'امروز سررسید بدهی توست' : 'امروز سررسید طلب توست',
            d.isDebt ? 'پرداخت $a به $who' : 'دریافت $a از $who',
            payload: 'debt:${d.payId}',
          ),
        );
      }
    }

    // خلاصه‌ی معوقات برای ۵ صبح آینده
    for (var i = 0; i < 5; i++) {
      final day = today.add(Duration(days: i));
      final at = _at9(day);
      if (!at.isAfter(now)) continue;
      final overdue = open
          .where((d) => _date(d.endedDate!).isBefore(day))
          .length;
      if (overdue > 0) {
        out.add(
          ScheduledAlert(
            900000 + i,
            at,
            'موارد معوق',
            '${fa('$overdue')} مورد سررسیدش گذشته است.',
            payload: 'open',
          ),
        );
      }
    }

    // رویدادهای حقوق و بودجه (تاریخ آن‌ها از سرور می‌آید)
    for (final a in _last?.alerts ?? const <BudgetAlert>[]) {
      final dt = a.date;
      if (dt == null) continue;
      final at = _at9(_date(dt));
      if (!at.isAfter(now)) continue;
      out.add(
        ScheduledAlert(
          a.key.hashCode & 0x3fffffff,
          at,
          a.title,
          a.message,
          payload: 'open',
        ),
      );
    }

    out.sort((a, b) => a.at.compareTo(b.at));
    await DeviceAlerts.replaceSchedule(out.take(60).toList());
  }
}
