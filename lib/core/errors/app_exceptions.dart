/// Jerarquía de errores de la capa de datos. Las vistas nunca ven
/// excepciones de http, solo estas.
abstract class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.errorCode});

  /// Mensaje legible (detalle del backend cuando existe).
  final String message;
  final int? statusCode;

  /// Código interno del contrato (PARAMETROS_INVALIDOS, ERROR_INTERNO…).
  final String? errorCode;

  /// true si el error justifica usar la caché (sin red / timeout).
  bool get isConnectivityIssue => false;

  @override
  String toString() => '$runtimeType($statusCode/$errorCode): $message';
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Sin conexión a Internet.']);
  @override
  bool get isConnectivityIssue => true;
}

class ApiTimeoutException extends AppException {
  const ApiTimeoutException([
    super.message = 'El servidor tardó demasiado en responder.',
  ]);
  @override
  bool get isConnectivityIssue => true;
}

/// 400 PARAMETROS_INVALIDOS -> mostrar mensaje de validación.
class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Los parámetros enviados no son válidos.',
    String? code,
  ]) : super(statusCode: 400, errorCode: code ?? 'PARAMETROS_INVALIDOS');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Sesión no válida o expirada.'])
      : super(statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'No tienes permisos para esta acción.',
  ]) : super(statusCode: 403);
}

/// 404 DATOS_NO_ENCONTRADOS -> mostrar estado sin datos.
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'No se encontraron datos para el criterio solicitado.',
    String? code,
  ]) : super(statusCode: 404, errorCode: code ?? 'DATOS_NO_ENCONTRADOS');
}

/// 422 PREDICCION_NO_DISPONIBLE -> mostrar mensaje informativo.
class PredictionUnavailableException extends AppException {
  const PredictionUnavailableException([
    super.message = 'No existen datos suficientes para realizar la predicción.',
    String? code,
  ]) : super(statusCode: 422, errorCode: code ?? 'PREDICCION_NO_DISPONIBLE');
}

/// 500 ERROR_INTERNO -> mostrar error general y permitir reintentar.
class ServerException extends AppException {
  const ServerException([
    super.message = 'Error interno del servidor.',
    int? code,
    String? errorCode,
  ]) : super(statusCode: code ?? 500, errorCode: errorCode ?? 'ERROR_INTERNO');
}

class ParseException extends AppException {
  const ParseException([
    super.message = 'La respuesta del servidor no tiene el formato esperado.',
  ]);
}

class UnknownApiException extends AppException {
  const UnknownApiException([
    super.message = 'Ocurrió un error inesperado.',
    int? code,
  ]) : super(statusCode: code);
}
