import '../../core/utils/json_utils.dart';

/// Respuesta de POST /api/auth/login.
///
/// Es tolerante con el nombre del campo del token (accessToken, access_token,
/// token, jwt) y con que venga envuelta en {"data": {...}}, porque el backend
/// real puede variar respecto al mock. El rol se lee de la respuesta si viene;
/// si no, se obtiene del JWT.
class AuthResponse {
  const AuthResponse({
    this.success = true,
    required this.accessToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
    this.role,
  });

  final bool success;
  final String accessToken;
  final String tokenType;

  /// Vigencia en segundos (si el backend la envía).
  final int? expiresIn;

  /// CANDIDATO, EMPRESA, ADMIN o SUPER_ADMIN (si viene en la respuesta).
  final String? role;

  static const _tokenKeys = ['accessToken', 'access_token', 'token', 'jwt'];
  static const _roleKeys = ['role', 'rol', 'roles'];

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final inner = json['data'];
    final src = inner is Map ? Map<String, dynamic>.from(inner) : json;

    String token = '';
    for (final k in _tokenKeys) {
      final v = src[k] ?? json[k];
      if (v is String && v.isNotEmpty) {
        token = v;
        break;
      }
    }

    String? role;
    for (final k in _roleKeys) {
      final v = src[k] ?? json[k];
      if (v is String && v.isNotEmpty) {
        role = v;
        break;
      }
      if (v is List && v.isNotEmpty) {
        role = asString(v.first);
        break;
      }
    }

    final expires = src['expiresIn'] ?? src['expires_in'];

    return AuthResponse(
      success: (json['success'] is bool) ? json['success'] as bool : true,
      accessToken: token,
      tokenType: asString(src['tokenType'] ?? src['token_type'], 'Bearer'),
      expiresIn: expires == null ? null : asInt(expires),
      role: role,
    );
  }
}
