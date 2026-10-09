// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HorizontePrediccion _$HorizontePrediccionFromJson(Map<String, dynamic> json) =>
    HorizontePrediccion(
      inicio: (json['inicio'] as num).toInt(),
      fin: (json['fin'] as num).toInt(),
    );

Paginacion _$PaginacionFromJson(Map<String, dynamic> json) => Paginacion(
      pagina: (json['pagina'] as num).toInt(),
      limite: (json['limite'] as num).toInt(),
      totalCargos: (json['total_cargos'] as num).toInt(),
      totalPaginas: (json['total_paginas'] as num).toInt(),
    );

PredictionResponse _$PredictionResponseFromJson(Map<String, dynamic> json) =>
    PredictionResponse(
      success: json['success'] as bool? ?? true,
      mensaje: json['mensaje'] as String? ?? '',
      fechaGeneracion: json['fecha_generacion'] == null
          ? null
          : DateTime.parse(json['fecha_generacion'] as String),
      horizontePrediccion: HorizontePrediccion.fromJson(
          json['horizonte_prediccion'] as Map<String, dynamic>),
      paginacion:
          Paginacion.fromJson(json['paginacion'] as Map<String, dynamic>),
      cargos: (json['cargos'] as List<dynamic>?)
              ?.map((e) => Cargo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
