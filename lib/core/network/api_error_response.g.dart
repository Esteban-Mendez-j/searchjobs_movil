// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiErrorResponse _$ApiErrorResponseFromJson(Map<String, dynamic> json) =>
    ApiErrorResponse(
      success: json['success'] as bool? ?? false,
      mensaje: json['mensaje'] as String? ?? '',
      error: json['error'] == null
          ? null
          : ApiErrorDetail.fromJson(json['error'] as Map<String, dynamic>),
    );

ApiErrorDetail _$ApiErrorDetailFromJson(Map<String, dynamic> json) =>
    ApiErrorDetail(
      codigo: json['codigo'] as String?,
      detalle: json['detalle'] as String?,
    );
