import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyRole = 'role';
  static const String _keyStatus = 'status';
  static const String _keyPeternak = 'peternak';
  static const String _keyIsLoggedIn = 'is_logged_in';

  static Future<void> saveUserSession({
    required String username,
    required String email,
    required String role,
    required String status,
    String? peternak,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyStatus, status);
    if (peternak != null) {
      await prefs.setString(_keyPeternak, peternak);
    }
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString(_keyUsername),
      'email': prefs.getString(_keyEmail),
      'role': prefs.getString(_keyRole),
      'status': prefs.getString(_keyStatus),
      'nama_peternak': prefs.getString(_keyPeternak),
    };
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

 static Future<void> clearSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyUsername);
  await prefs.remove(_keyEmail);
  await prefs.remove(_keyRole);
  await prefs.remove(_keyStatus);
  await prefs.remove(_keyPeternak);
  await prefs.remove(_keyIsLoggedIn);
}

}
