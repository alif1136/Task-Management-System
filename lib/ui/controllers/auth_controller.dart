import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/data/models/user_model.dart';

class AuthController {
  static const String _tokenKey = 'token_key';
  static const String _userKey = 'user_key';

  static String? accessToken;
  static UserModel? userData;

  // Called from SplashScreen
  static Future<bool> isUserAlreadyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_tokenKey);
    return accessToken != null && accessToken!.isNotEmpty;
  }

  // Load user data for logged-in user
  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_userKey);

    if (encoded == null) return null;

    final Map<String, dynamic> decoded = jsonDecode(encoded);
    userData = UserModel.fromJson(decoded);

    return userData;
  }

  // Save token on login
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    accessToken = token;
  }

  // Save user data on login
  static Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    userData = user;
  }

  // Update user after profile update
  static Future<void> updateUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    userData = user;
  }

  // Logout
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    accessToken = null;
    userData = null;
  }
}
