import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json_utils.dart';

class PredictionService {
  PredictionService(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> fetchRaw({
    int pagina = AppConfig.defaultPage,
    int limite = AppConfig.defaultLimit,
    String? cargoId,
  }) async {
    // La app numera las páginas desde 1; el backend real, desde 0.
    final paginaServidor = AppConfig.isMock ? pagina : pagina - 1;

    final data = await _api.get(
      AppConfig.predictionsPath,
      query: {
        'pagina': '$paginaServidor',
        'limite': '$limite',
        if (cargoId != null && cargoId.isNotEmpty) 'cargo_name': cargoId,
      },
    );
    if (data is! Map) throw const ParseException();
    final root = Map<String, dynamic>.from(data);

    // Mock de Postman: ya viene en el formato de la app.
    final inner = root['data'];
    if (inner is! Map) return root;

    // Backend real: {"data": {...}, "meta": {"pagination": {...}}, "error": ...}
    final map = Map<String, dynamic>.from(inner);
    if (map['paginacion'] == null) {
      final meta = root['meta'];
      final p = meta is Map ? meta['pagination'] : null;
      if (p is Map) {
        final actual = p['pageActual'];
        final numero =
            actual is Map ? asInt(actual['pageNumber']) : paginaServidor;
        final tamano = actual is Map ? asInt(actual['pageSize'], limite) : limite;
        map['paginacion'] = {
          'pagina': numero + 1, // de vuelta a base 1 para la app
          'limite': tamano,
          'total_cargos': asInt(p['totalElements']),
          'total_paginas': asInt(p['totalPage']),
        };
      }
    }
    return map;
  }
}