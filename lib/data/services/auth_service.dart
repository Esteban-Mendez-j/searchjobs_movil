import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/auth_response.dart';

class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      AppConfig.loginPath,
      body: {'username': email, 'password': password},
      authenticated: false,
    );
    if (data is! Map<String, dynamic>) throw const ParseException();

    final AuthResponse response;
    try {
      response = AuthResponse.fromJson(data);
    } catch (_) {
      throw const ParseException(
        'La respuesta de autenticación no contiene un token.',
      );
    }
    if (!response.success || response.accessToken.isEmpty) {
      throw const UnauthorizedException('No fue posible iniciar sesión.');
    }
    return response;
  }
}
