import '../services/preferences_service.dart';

class AuthRepository {
  AuthRepository({required PreferencesService preferences}) : _preferences = preferences;
  final PreferencesService _preferences;
  Future<bool> hasAccount() async => (await _preferences.username) != null;
  Future<bool> login(String username, String password) => _preferences.validate(username, password);
  Future<void> save(String username, String password) => _preferences.saveCredentials(username: username, password: password);
}
