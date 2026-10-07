import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'my_money_token';

  final SharedPreferences preferences;

  TokenStorage(this.preferences);

  String? getToken() {
    return preferences.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    await preferences.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    await preferences.remove(_tokenKey);
  }
}
