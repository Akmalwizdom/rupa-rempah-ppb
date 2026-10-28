import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _usernameKey = 'username';
  static const _passwordKey = 'password';
  Future<SharedPreferences> get _storage => SharedPreferences.getInstance();
  Future<String?> get username async => (await _storage).getString(_usernameKey);
  Future<void> saveCredentials({required String username, required String password}) async {
    final storage = await _storage;
    await storage.setString(_usernameKey, username);
    await storage.setString(_passwordKey, password);
  }
  Future<bool> validate(String username, String password) async => username == await this.username && password == (await _storage).getString(_passwordKey);
}
