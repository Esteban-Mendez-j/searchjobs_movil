// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demanda_periodo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DemandaHistorica _$DemandaHistoricaFromJson(Map<String, dynamic> json) =>
    DemandaHistorica(
      periodo: (json['periodo'] as num).toInt(),
      cantidad: (json['cantidad'] as num).toDouble(),
    );

PrediccionPeriodo _$PrediccionPeriodoFromJson(Map<String, dynamic> json) =>
    PrediccionPeriodo(
      periodo: (json['periodo'] as num).toInt(),
      cantidadPredicha: (json['cantidad_predicha'] as num).toDouble(),
      limiteInferior: (json['limite_inferior'] as num?)?.toDouble(),
      limiteSuperior: (json['limite_superior'] as num?)?.toDouble(),
    );
