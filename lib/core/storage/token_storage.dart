import 'dart:convert';
import 'package:money/core/storage/app_storage.dart';

class TokenStorage {
  static const String _tokenKey = 'access_token';
  static const String _nameKey = 'user_name';

  final AppStorage _s;
  String? _token;
  String? _name;

  TokenStorage(this._s) {
    _token = _s.getString(_tokenKey);
    _name = _s.getString(_nameKey);
  }

  String? getToken() => _token;

  Future<void> saveToken(String token) async {
    _token = token;
    await _s.setString(_tokenKey, token);
  }

  String? getName() => _name;

  Future<void> saveName(String name) async {
    _name = name;
    await _s.setString(_nameKey, name);
  }

  Future<void> clearAll() async {
    _token = null;
    _name = null;
    await _s.remove(_tokenKey);
    await _s.remove(_nameKey);
  }

  /// توکن وجود دارد و منقضی نشده است
  bool get isLoggedIn {
    final t = _token;
    if (t == null || t.isEmpty) return false;
    return !_isExpired(t);
  }

  /// بدون فیلد exp (توکن بی‌انقضا) منقضی حساب نمی‌شود
  static bool _isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload =
          jsonDecode(
                utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
              )
              as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! num) return false;
      final now = DateTime.now().toUtc().millisecondsSinceEpoch / 1000;
      return now >= exp - 30;
    } catch (_) {
      return false; // خراب بودن parse نباید کاربر را بیرون بیندازد؛ سرور تصمیم می‌گیرد
    }
  }
}
