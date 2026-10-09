import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnvironment { mock, production }

class AppConfig {
  AppConfig._();

  static Future<void> load() => dotenv.load(fileName: '.env', isOptional: true);

  static const String _defaultMockUrl =
      'https://eb1404ef-01a6-4cd9-a356-d2edd23adc5f.mock.pstmn.io';
  static const String _defaultProdUrl = 'http://10.0.2.2:8080';

  static String _get(String key, String fallback) {
    if (!dotenv.isInitialized) return fallback;
    final value = dotenv.maybeGet(key)?.trim();
    return (value == null || value.isEmpty) ? fallback : value;
  }

  static AppEnvironment get environment {
    final env = _get('ENV', 'mock').toLowerCase();
    return (env == 'prod' || env == 'production')
        ? AppEnvironment.production
        : AppEnvironment.mock;
  }

  static bool get isMock => environment == AppEnvironment.mock;

  static String get baseUrl {
    final url = isMock
        ? _get('MOCK_URL', _defaultMockUrl)
        : _get('PROD_URL', _defaultProdUrl);
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Endpoints
  static const String predictionsPath = '/api/predicciones/demanda-laboral';
  static const String loginPath = '/api/auth';

  // Tiempos y reintentos para solicitudes
  static const Duration requestTimeout = Duration(seconds: 15);
  static const int maxRetries = 1; // reintentos solo para GET (timeout / red)
  static const Duration retryDelay = Duration(milliseconds: 600);

  // JWT: nombre del header y prefijo del valor.
  static const String authHeaderName = 'Authorization';
  static const String authScheme = 'Bearer ';

  // Paginación por defecto
  static const int defaultPage = 1;
  static const int defaultLimit = 5;
}
