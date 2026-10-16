import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money/core/alerts/alert_models.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class DeviceAlerts {
  DeviceAlerts._();
  static final _p = FlutterLocalNotificationsPlugin();

  static bool get supportsSchedule => true;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'due_alerts',
      'سررسید و بودجه',
      channelDescription: 'یادآوری سررسید بدهی و طلب، حقوق و بودجه',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> init(void Function(String payload) onTap) async {
    tzdata.initializeTimeZones();
    await _p.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload;
        if (p != null && p.isNotEmpty) onTap(p);
      },
    );
  }

  static Future<bool> isGranted() async {
    final a = _p
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (a != null) return await a.areNotificationsEnabled() ?? false;
    final i = _p
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final o = await i?.checkPermissions();
    return o?.isEnabled ?? false;
  }

  static Future<bool> requestPermission() async {
    final a = _p
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (a != null) return await a.requestNotificationsPermission() ?? false;
    final i = _p
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await i?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  static Future<void> show(
    int id,
    String title,
    String body, {
    String? payload,
  }) => _p.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: _details,
    payload: payload,
  );

  /// همه‌ی زمان‌بندی‌های قبلی پاک و فهرست جدید جایگزین می‌شود
  static Future<void> replaceSchedule(List<ScheduledAlert> items) async {
    await cancelScheduled();
    final now = DateTime.now();
    for (final a in items) {
      if (!a.at.isAfter(now)) continue;
      await _p.zonedSchedule(
        id: a.id,
        title: a.title,
        body: a.body,
        // زمان محلی به لحظه‌ی دقیق تبدیل می‌شود؛ مستقل از منطقه‌ی زمانی دستگاه
        scheduledDate: tz.TZDateTime.from(a.at, tz.UTC),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: a.payload,
      );
    }
  }

  static Future<void> cancelScheduled() async {
    for (final r in await _p.pendingNotificationRequests()) {
      await _p.cancel(id: r.id);
    }
  }

  static Future<void> cancelAll() => _p.cancelAll();
}
