import 'package:get_it/get_it.dart';
import 'package:money/core/network/notification_read_store.dart';
import 'package:money/core/storage/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// هر چیزی که مخصوص کاربر است و باید موقع خروج یا حذف حساب پاک شود
class SessionCleaner {
  SessionCleaner._();

  static Future<void> clear() async {
    final g = GetIt.I;
    await g<TokenStorage>().clearAll();
    await g<NotificationReadStore>().clear();
    await g<SharedPreferences>().remove('recent_searches');
  }
}
