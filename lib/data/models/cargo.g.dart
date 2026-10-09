// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cargo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cargo _$CargoFromJson(Map<String, dynamic> json) => Cargo(
      id: (json['id'] as num).toInt(),
      nombre: json['nombre'] as String,
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
      requisitos: (json['requisitos'] as List<dynamic>?)
              ?.map((e) => Requisito.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
