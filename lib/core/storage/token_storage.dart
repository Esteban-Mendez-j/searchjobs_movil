import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el JWT y su vigencia en el almacenamiento seguro (Keychain / Keystore).
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';
  static const _expiresKey = 'jwt_expires_at';
  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  /// [expiresInSeconds] viene del campo `expiresIn` de la respuesta de /api/auth.
  Future<void> saveSession(String token, {int? expiresInSeconds}) async {
    await _storage.write(key: _tokenKey, value: token);
    if (expiresInSeconds != null && expiresInSeconds > 0) {
      final at = DateTime.now().add(Duration(seconds: expiresInSeconds));
      await _storage.write(
          key: _expiresKey, value: at.millisecondsSinceEpoch.toString());
    } else {
      await _storage.delete(key: _expiresKey);
    }
  }

  /// true si `expiresIn` indicó una vigencia y ya se superó.
  Future<bool> isExpired({Duration leeway = const Duration(seconds: 30)}) async {
    final raw = await _storage.read(key: _expiresKey);
    final ms = int.tryParse(raw ?? '');
    if (ms == null) return false;
    return DateTime.now()
        .isAfter(DateTime.fromMillisecondsSinceEpoch(ms).subtract(leeway));
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiresKey);
  }
}
