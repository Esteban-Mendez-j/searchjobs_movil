import 'dart:convert';

/// Utilidades para leer un JWT en el cliente (sin verificar firma;
/// eso siempre lo hace el backend).
class JwtUtils {
  JwtUtils._();

  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = jsonDecode(json);
      return map is Map<String, dynamic> ? map : null;
    } catch (_) {
      return null;
    }
  }

  static DateTime? expirationDate(String token) {
    final exp = decodePayload(token)?['exp'];
    if (exp is num) {
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
    }
    return null;
  }

  /// Si el token no trae `exp` se asume vigente y decide el servidor (401).
  static bool isExpired(String token,
      {Duration leeway = const Duration(seconds: 30)}) {
    final exp = expirationDate(token);
    if (exp == null) return false;
    return DateTime.now().toUtc().isAfter(exp.subtract(leeway));
  }
}
