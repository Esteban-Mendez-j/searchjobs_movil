import 'package:flutter/foundation.dart';

import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo, ApiClient apiClient) {
    apiClient.onUnauthorized = _onSessionExpired;
  }

  final AuthRepository _repo;

  AuthStatus _status = AuthStatus.unknown;
  bool _loading = false;
  String? _error;

  AuthStatus get status => _status;
  bool get isLoading => _loading;
  String? get errorMessage => _error;

  Future<void> init() async {
    final ok = await _repo.hasValidSession();
    _status = ok ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repo.login(email.trim(), password);
      _status = AuthStatus.authenticated;
    } on UnauthorizedException {
      _error = 'Correo o contraseña incorrectos.';
    } on NetworkException {
      _error = 'Sin conexión a Internet. Inténtalo de nuevo.';
    } on ApiTimeoutException {
      _error = 'El servidor tardó demasiado en responder.';
    } on AppException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _error = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void _onSessionExpired() {
    if (_status != AuthStatus.authenticated) return;
    _status = AuthStatus.unauthenticated;
    _error = 'Tu sesión expiró. Inicia sesión nuevamente.';
    notifyListeners();
  }
}
