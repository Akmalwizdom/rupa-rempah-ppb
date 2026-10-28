import 'package:flutter/foundation.dart';
import '../../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository repository}) : _repository = repository;
  final AuthRepository _repository;
  bool isLoading = false;
  String? errorMessage;
  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) { errorMessage = 'Username dan password wajib diisi.'; notifyListeners(); return false; }
    isLoading = true; errorMessage = null; notifyListeners();
    final valid = await _repository.login(username.trim(), password);
    isLoading = false; if (!valid) errorMessage = 'Username atau password belum sesuai.'; notifyListeners(); return valid;
  }
}
