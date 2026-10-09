import 'package:json_annotation/json_annotation.dart';

part 'demanda_periodo.g.dart';

/// {"periodo": 2024, "cantidad": 520}
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class DemandaHistorica {
  const DemandaHistorica({required this.periodo, required this.cantidad});

  final int periodo;
  final double cantidad;

  factory DemandaHistorica.fromJson(Map<String, dynamic> json) =>
      _$DemandaHistoricaFromJson(json);
}

/// {"periodo": 2027, "cantidad_predicha": 980, "limite_inferior": 900, "limite_superior": 1060}
@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class PrediccionPeriodo {
  const PrediccionPeriodo({
    required this.periodo,
    required this.cantidadPredicha,
    this.limiteInferior,
    this.limiteSuperior,
  });

  final int periodo;
  final double cantidadPredicha;
  final double? limiteInferior;
  final double? limiteSuperior;

  factory PrediccionPeriodo.fromJson(Map<String, dynamic> json) =>
      _$PrediccionPeriodoFromJson(json);
}
