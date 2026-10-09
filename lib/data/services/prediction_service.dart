import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';

/// GET /api/predicciones/demanda-laboral?pagina=&limite=&cargo_id=
/// Devuelve el JSON crudo para que el repositorio lo cachee tal cual.
class PredictionService {
  PredictionService(this._api);
  final ApiClient _api;

  Future<Map<String, dynamic>> fetchRaw({
    int pagina = AppConfig.defaultPage,
    int limite = AppConfig.defaultLimit,
    String? cargoId,
  }) async {
    final data = await _api.get(
      AppConfig.predictionsPath,
      query: {
        'pagina': '$pagina',
        'limite': '$limite',
        if (cargoId != null && cargoId.isNotEmpty) 'cargo_id': cargoId,
      },
    );
    if (data is! Map) throw const ParseException();
    return Map<String, dynamic>.from(data);
  }
}
