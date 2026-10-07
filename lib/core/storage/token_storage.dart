import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'access_token';

  SharedPreferences? _prefs;
  String? _cachedToken;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _cachedToken = _prefs?.getString(_tokenKey);
  }

  String? getToken() {
    return _cachedToken;
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _prefs?.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    await _prefs?.remove(_tokenKey);
  }

  bool get isLoggedIn {
    return _cachedToken != null && _cachedToken!.isNotEmpty;
  }
}
