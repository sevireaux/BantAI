import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage (Android Keystore-backed) for the Sanctum
/// bearer token and a small cache of the current user's identity, so the
/// app can restore a session without a network round-trip on launch.
class TokenStorage {
  TokenStorage._();
  static final instance = TokenStorage._();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'bantai_token';
  static const _userKey = 'bantai_user_json';

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveUserJson(String json) => _storage.write(key: _userKey, value: json);
  Future<String?> readUserJson() => _storage.read(key: _userKey);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
