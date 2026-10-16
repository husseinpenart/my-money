import 'dart:js_interop';
import 'package:money/core/alerts/alert_models.dart';
import 'package:web/web.dart' as web;

/// وب: فقط وقتی تب باز است. زمان‌بندی پشت‌زمینه ندارد (نیاز به Web Push سروری)
class DeviceAlerts {
  DeviceAlerts._();
  static void Function(String payload)? _onTap;

  static bool get supportsSchedule => false;

  static Future<void> init(void Function(String payload) onTap) async {
    _onTap = onTap;
  }

  static Future<bool> isGranted() async {
    try {
      return web.Notification.permission == 'granted';
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final r = await web.Notification.requestPermission().toDart;
      return r.toDart == 'granted';
    } catch (_) {
      return false; // مرورگر پشتیبانی نمی‌کند
    }
  }

  static Future<void> show(
    int id,
    String title,
    String body, {
    String? payload,
  }) async {
    try {
      if (!await isGranted()) return;
      final n = web.Notification(
        title,
        web.NotificationOptions(body: body, tag: '$id', lang: 'fa', dir: 'rtl'),
      );
      n.onclick = ((web.Event _) {
        web.window.focus();
        n.close();
        if (payload != null) _onTap?.call(payload);
      }).toJS;
    } catch (_) {}
  }

  static Future<void> replaceSchedule(List<ScheduledAlert> items) async {}
  static Future<void> cancelScheduled() async {}
  static Future<void> cancelAll() async {}
}
