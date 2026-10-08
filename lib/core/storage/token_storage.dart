// lib/core/storage/token_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'access_token';
  final SharedPreferences _prefs;
  String? _cachedToken;

  // شِیرد پرفرنسز را مستقیماً دریافت می‌کند
  TokenStorage(this._prefs) {
    _cachedToken = _prefs.getString(_tokenKey);
  }

  String? getToken() {
    return _cachedToken ?? _prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    await _prefs.remove(_tokenKey);
  }

  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}
