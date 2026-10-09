import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/app_exceptions.dart';
import '../storage/token_storage.dart';
import '../utils/jwt_utils.dart';
import 'api_error_response.dart';

/// Cliente HTTP único de la app: timeout, reintentos, JWT y mapeo de errores.
class ApiClient {
  ApiClient({required http.Client client, required TokenStorage tokenStorage})
    : _client = client,
      _tokens = tokenStorage;

  final http.Client _client;
  final TokenStorage _tokens;

  /// Se invoca cuando el token no existe, expiró o el servidor responde 401.
  VoidCallback? onUnauthorized;

  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool authenticated = true,
  }) => _request(
    'GET',
    path,
    query: query,
    authenticated: authenticated,
    retries: AppConfig.maxRetries,
  );

  Future<dynamic> post(
    String path, {
    Object? body,
    bool authenticated = true,
  }) => _request('POST', path, body: body, authenticated: authenticated);

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool authenticated = true,
    int retries = 0,
  }) async {
    final headers = await _buildHeaders(authenticated);
    final uri = _buildUri(path, query);
    var attempt = 0;

    while (true) {
      try {
        if (kDebugMode) debugPrint('[API] $method $uri');
        final response = await _send(
          method,
          uri,
          headers,
          body,
        ).timeout(AppConfig.requestTimeout);
        return await _handleResponse(response, authenticated);
      } on TimeoutException {
        if (attempt++ < retries) {
          await Future.delayed(AppConfig.retryDelay);
          continue;
        }
        throw const ApiTimeoutException();
      } on AppException {
        rethrow;
      } catch (_) {
        // SocketException, ClientException, HandshakeException, etc.
        if (attempt++ < retries) {
          await Future.delayed(AppConfig.retryDelay);
          continue;
        }
        throw const NetworkException();
      }
    }
  }

  Future<http.Response> _send(
    String method,
    Uri uri,
    Map<String, String> headers,
    Object? body,
  ) {
    switch (method) {
      case 'POST':
        return _client.post(uri, headers: headers, body: jsonEncode(body));
      default:
        return _client.get(uri, headers: headers);
    }
  }

  Uri _buildUri(String path, Map<String, String>? query) {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    return (query == null || query.isEmpty)
        ? uri
        : uri.replace(queryParameters: query);
  }

  Future<Map<String, String>> _buildHeaders(bool authenticated) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await _tokens.readToken();
      if (token == null ||
          JwtUtils.isExpired(token) ||
          await _tokens.isExpired()) {
        await _tokens.deleteToken();
        onUnauthorized?.call();
        throw const UnauthorizedException();
      }
      headers[AppConfig.authHeaderName] = '${AppConfig.authScheme}$token';
    }
    return headers;
  }

  Future<dynamic> _handleResponse(http.Response r, bool authenticated) async {
    final code = r.statusCode;

    if (code >= 200 && code < 300) {
      if (r.bodyBytes.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(r.bodyBytes));
      } on FormatException {
        throw const ParseException();
      }
    }

    final error = _parseError(r);
    final message = error?.bestMessage;
    final codigo = error?.error?.codigo;

    switch (code) {
      case 400:
        throw ValidationException(
          message ?? 'Los parámetros enviados no son válidos.',
          codigo,
        );
      case 401:
        if (authenticated) {
          await _tokens.deleteToken();
          onUnauthorized?.call();
        }
        throw UnauthorizedException(message ?? 'Sesión no válida o expirada.');
      case 403:
        throw ForbiddenException(
          message ?? 'No tienes permisos para esta acción.',
        );
      case 404:
        throw NotFoundException(
          message ?? 'No se encontraron datos para el criterio solicitado.',
          codigo,
        );
      case 422:
        throw PredictionUnavailableException(
          message ??
              'No existen datos suficientes para realizar la predicción.',
          codigo,
        );
      default:
        if (code >= 500) {
          throw ServerException(
            message ?? 'Error interno del servidor.',
            code,
            codigo,
          );
        }
        throw UnknownApiException(message ?? 'Error inesperado ($code).', code);
    }
  }

  /// Lee el cuerpo de error del contrato; null si no tiene ese formato.
  ApiErrorResponse? _parseError(http.Response r) {
    try {
      final body = jsonDecode(utf8.decode(r.bodyBytes));
      if (body is Map<String, dynamic>) return ApiErrorResponse.fromJson(body);
    } catch (_) {}
    return null;
  }
}
