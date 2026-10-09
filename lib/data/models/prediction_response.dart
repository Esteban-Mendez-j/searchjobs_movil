import 'package:json_annotation/json_annotation.dart';

import 'cargo.dart';

part 'prediction_response.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class HorizontePrediccion {
  const HorizontePrediccion({required this.inicio, required this.fin});

  final int inicio;
  final int fin;

  factory HorizontePrediccion.fromJson(Map<String, dynamic> json) =>
      _$HorizontePrediccionFromJson(json);
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Paginacion {
  const Paginacion({
    required this.pagina,
    required this.limite,
    required this.totalCargos,
    required this.totalPaginas,
  });

  final int pagina;
  final int limite;
  final int totalCargos;
  final int totalPaginas;

  bool get hayMasPaginas => pagina < totalPaginas;

  factory Paginacion.fromJson(Map<String, dynamic> json) =>
      _$PaginacionFromJson(json);
}

/// Respuesta 200 de GET /api/predicciones/demanda-laboral
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class PredictionResponse {
  const PredictionResponse({
    this.success = true,
    this.mensaje = '',
    this.fechaGeneracion,
    required this.horizontePrediccion,
    required this.paginacion,
    this.cargos = const [],
  });

  @JsonKey(defaultValue: true)
  final bool success;

  @JsonKey(defaultValue: '')
  final String mensaje;

  final DateTime? fechaGeneracion;
  final HorizontePrediccion horizontePrediccion;
  final Paginacion paginacion;

  @JsonKey(defaultValue: <Cargo>[])
  final List<Cargo> cargos;

  factory PredictionResponse.fromJson(Map<String, dynamic> json) =>
      _$PredictionResponseFromJson(json);
}
