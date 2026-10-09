import 'package:json_annotation/json_annotation.dart';

import 'demanda_metrics.dart';
import 'demanda_periodo.dart';

part 'requisito.g.dart';

/// Requisito asociado a un cargo (Python, Java, SQL…).
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Requisito with DemandaMetrics {
  const Requisito({
    required this.id,
    required this.nombre,
    this.tipo = '',
    this.demandaHistorica = const [],
    this.prediccion = const [],
    this.crecimientoEstimado = 0,
  });

  final int id;
  final String nombre;

  /// TECNOLOGIA, HERRAMIENTA, CONOCIMIENTO, COMPETENCIA o CERTIFICACION.
  @JsonKey(defaultValue: '')
  final String tipo;

  @override
  @JsonKey(defaultValue: <DemandaHistorica>[])
  final List<DemandaHistorica> demandaHistorica;

  @override
  @JsonKey(defaultValue: <PrediccionPeriodo>[])
  final List<PrediccionPeriodo> prediccion;

  @override
  @JsonKey(defaultValue: 0.0)
  final double crecimientoEstimado;

  factory Requisito.fromJson(Map<String, dynamic> json) =>
      _$RequisitoFromJson(json);
}
