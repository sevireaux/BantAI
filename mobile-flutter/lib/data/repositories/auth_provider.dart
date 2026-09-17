import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/api_client.dart';
import '../../core/token_storage.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  ApiUser? _user;
  bool _initializing = true;

  ApiUser? get user => _user;
  bool get initializing => _initializing;
  bool get isAuthenticated => _user != null;

  /// Call once at app startup — restores a session from secure storage
  /// without a network round-trip, so the app opens instantly even offline.
  Future<void> restoreSession() async {
    final token = await TokenStorage.instance.readToken();
    final userJson = await TokenStorage.instance.readUserJson();
    if (token != null && userJson != null) {
      _user = ApiUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    _initializing = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final res = await ApiClient.instance.post('/auth/login', data: {'email': email, 'password': password});
    await _persistSession(res);
  }

  Future<void> signup(String name, String email, String password) async {
    final res = await ApiClient.instance.post('/auth/signup', data: {'name': name, 'email': email, 'password': password});
    await _persistSession(res);
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {
      // Best-effort — clear the local session regardless of network state.
    }
    await TokenStorage.instance.clear();
    _user = null;
    notifyListeners();
  }

  Future<void> _persistSession(Map<String, dynamic> res) async {
    final token = res['token'] as String;
    final userJson = res['user'] as Map<String, dynamic>;
    await TokenStorage.instance.saveToken(token);
    await TokenStorage.instance.saveUserJson(jsonEncode(userJson));
    _user = ApiUser.fromJson(userJson);
    notifyListeners();
  }
}
