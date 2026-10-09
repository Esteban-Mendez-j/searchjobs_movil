import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/network/api_client.dart';

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
        if (cargoId != null && cargoId.isNotEmpty) 'cargo_name': cargoId,
      },
    );
    if (data is! Map) throw const ParseException();
    return Map<String, dynamic>.from(data);
  }
}
