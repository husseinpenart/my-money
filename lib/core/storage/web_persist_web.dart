import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// از مرورگر می‌خواهد داده‌ی این سایت را هنگام کمبود فضا پاک نکند
Future<void> requestPersistentStorage() async {
  try {
    await web.window.navigator.storage.persist().toDart;
  } catch (_) {}
}
