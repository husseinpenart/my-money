import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// موبایل: SharedPreferences. وب: IndexedDB (Hive) با انتقال خودکار از localStorage.
/// خواندن همیشه همگام است (از حافظه)، پس بقیه‌ی کد تغییری نمی‌کند.
class AppStorage {
  AppStorage._(this._prefs, this._box);

  final SharedPreferences _prefs;
  final Box<String>? _box;

  /// اگر هر دو انبار خراب بودند (مثلاً حالت ناشناس سخت‌گیر)، برنامه هنوز در همان نشست کار کند
  final Map<String, String> _mem = {};

  /// فقط کلیدهای خود برنامه منتقل می‌شوند
  static const _legacyKeys = [
    'access_token',
    'user_name',
    'cache_contacts_v1',
    'notif_read_keys',
    'recent_searches',
  ];

  static Future<AppStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!kIsWeb) return AppStorage._(prefs, null);

    Box<String>? box;
    try {
      await Hive.initFlutter();
      box = await Hive.openBox<String>('app_storage');

      for (final k in _legacyKeys) {
        if (!prefs.containsKey(k) || box.containsKey(k)) continue;
        final v = prefs.get(k);
        if (v is String) {
          await box.put(k, v);
        } else if (v is List<String>) {
          await box.put(k, jsonEncode(v));
        } else {
          continue;
        }
        await prefs.remove(k);
      }
    } catch (_) {
      box = null; // IndexedDB در دسترس نیست؛ به localStorage برمی‌گردیم
    }
    return AppStorage._(prefs, box);
  }

  // ───────────── رشته ─────────────
  String? getString(String key) {
    if (_mem.containsKey(key)) return _mem[key];
    if (_box != null) return _box.get(key);
    try {
      return _prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> setString(String key, String value) async {
    _mem[key] = value;
    try {
      if (_box != null) {
        await _box.put(key, value);
      } else {
        await _prefs.setString(key, value);
      }
      _mem.remove(key); // با موفقیت ذخیره شد؛ نیازی به نسخه‌ی موقت نیست
    } catch (_) {
      // پر بودن حافظه یا خطای مرورگر: همین نشست با نسخه‌ی حافظه ادامه می‌دهد
    }
  }

  // ───────────── فهرست رشته‌ها ─────────────
  List<String>? getStringList(String key) {
    final s = getString(key);
    if (s == null) return null;
    try {
      return (jsonDecode(s) as List).map((e) => '$e').toList();
    } catch (_) {
      // مقدار قدیمی که با SharedPreferences.setStringList ذخیره شده
      try {
        return _prefs.getStringList(key);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> setStringList(String key, List<String> value) =>
      setString(key, jsonEncode(value));

  // ───────────── حذف ─────────────
  Future<void> remove(String key) async {
    _mem.remove(key);
    try {
      await _box?.delete(key);
      await _prefs.remove(key);
    } catch (_) {}
  }
}
