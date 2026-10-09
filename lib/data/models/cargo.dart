import 'package:json_annotation/json_annotation.dart';

import 'demanda_metrics.dart';
import 'demanda_periodo.dart';
import 'requisito.dart';

part 'cargo.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class Cargo with DemandaMetrics {
  const Cargo({
    required this.id,
    required this.nombre,
    this.demandaHistorica = const [],
    this.prediccion = const [],
    this.crecimientoEstimado = 0,
    this.requisitos = const [],
  });

  final int id;
  final String nombre;

  @override
  @JsonKey(defaultValue: <DemandaHistorica>[])
  final List<DemandaHistorica> demandaHistorica;

  @override
  @JsonKey(defaultValue: <PrediccionPeriodo>[])
  final List<PrediccionPeriodo> prediccion;

  @override
  @JsonKey(defaultValue: 0.0)
  final double crecimientoEstimado;

  @JsonKey(defaultValue: <Requisito>[])
  final List<Requisito> requisitos;

  factory Cargo.fromJson(Map<String, dynamic> json) => _$CargoFromJson(json);

  /// Id como texto (para chips, selección y parámetro cargo_id).
  String get cargoId => '$id';

  /// Nombre corto para chips y gráficos:
  /// "Desarrollador de software" -> "Dev. Software".
  String get etiqueta {
    var s = nombre.trim();
    const prefijos = {
      'Desarrollador de ': 'Dev. ',
      'Desarrollador ': 'Dev. ',
      'Ingeniero de ': 'Ing. ',
      'Ingeniero ': 'Ing. ',
    };
    for (final e in prefijos.entries) {
      if (s.startsWith(e.key)) {
        s = s.replaceFirst(e.key, e.value);
        break;
      }
    }
    s = s.replaceAll(' de ', ' ').replaceAll(' del ', ' ');
    return s
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
