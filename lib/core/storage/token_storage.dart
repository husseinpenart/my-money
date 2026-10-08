// lib/core/storage/token_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'access_token';
  static const String _nameKey = 'user_name'; // کلید جدید برای ذخیره نام

  final SharedPreferences _prefs;
  String? _cachedToken;
  String? _cachedName;

  TokenStorage(this._prefs) {
    _cachedToken = _prefs.getString(_tokenKey);
    _cachedName = _prefs.getString(_nameKey);
  }

  // --- مدیریت توکن ---
  String? getToken() => _cachedToken ?? _prefs.getString(_tokenKey);

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _prefs.setString(_tokenKey, token);
  }

  // --- مدیریت نام کاربر ---
  String? getName() => _cachedName ?? _prefs.getString(_nameKey);

  Future<void> saveName(String name) async {
    _cachedName = name;
    await _prefs.setString(_nameKey, name);
  }

  // --- خروج از حساب ---
  Future<void> clearAll() async {
    _cachedToken = null;
    _cachedName = null;
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_nameKey);
  }

  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}
