import 'package:json_annotation/json_annotation.dart';

part 'api_error_response.g.dart';

/// Contrato de error:
/// {"success": false, "mensaje": "...", "error": {"codigo": "...", "detalle": "..."}}
@JsonSerializable(createToJson: false)
class ApiErrorResponse {
  const ApiErrorResponse({this.success = false, this.mensaje = '', this.error});

  @JsonKey(defaultValue: false)
  final bool success;
  @JsonKey(defaultValue: '')
  final String mensaje;
  final ApiErrorDetail? error;

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorResponseFromJson(json);

  /// Mensaje más útil para el usuario: detalle > mensaje.
  String? get bestMessage {
    final detalle = error?.detalle;
    if (detalle != null && detalle.isNotEmpty) return detalle;
    return mensaje.isNotEmpty ? mensaje : null;
  }
}

@JsonSerializable(createToJson: false)
class ApiErrorDetail {
  const ApiErrorDetail({this.codigo, this.detalle});

  final String? codigo;
  final String? detalle;

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorDetailFromJson(json);
}
