import '../../core/storage/cache_storage.dart';
import '../../core/storage/token_storage.dart';
import '../../core/utils/jwt_utils.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository(this._service, this._tokens, this._cache);

  final AuthService _service;
  final TokenStorage _tokens;
  final CacheStorage _cache;

  Future<void> login(String email, String password) async {
    final auth = await _service.login(email: email, password: password);
    await _tokens.saveSession(auth.accessToken, expiresInSeconds: auth.expiresIn);
  }

  Future<bool> hasValidSession() async {
    final token = await _tokens.readToken();
    if (token == null || token.isEmpty) return false;
    if (JwtUtils.isExpired(token) || await _tokens.isExpired()) {
      await _tokens.deleteToken();
      return false;
    }
    return true;
  }

  Future<void> logout() async {
    await _tokens.deleteToken();
    await _cache.clear();
  }
}
