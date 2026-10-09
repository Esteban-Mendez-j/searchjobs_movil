// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requisito.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Requisito _$RequisitoFromJson(Map<String, dynamic> json) => Requisito(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
      tipo: json['tipo'] as String? ?? '',
      demandaHistorica: (json['demanda_historica'] as List<dynamic>?)
              ?.map((e) => DemandaHistorica.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      prediccion: (json['prediccion'] as List<dynamic>?)
              ?.map((e) => PrediccionPeriodo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      crecimientoEstimado:
          (json['crecimiento_estimado'] as num?)?.toDouble() ?? 0.0,
    );
