import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/storage/cache_storage.dart';
import '../models/prediction_response.dart';
import '../services/prediction_service.dart';

class PredictionResult {
  const PredictionResult(this.data, {this.fromCache = false, this.cachedAt});
  final PredictionResponse data;
  final bool fromCache;
  final DateTime? cachedAt;
}

/// Estrategia: red primero; si hay problema de conectividad, caché.
class PredictionRepository {
  PredictionRepository(this._service, this._cache);

  final PredictionService _service;
  final CacheStorage _cache;

  Future<PredictionResult> getPredictions({
    int pagina = AppConfig.defaultPage,
    int limite = AppConfig.defaultLimit,
    String? cargoId,
  }) async {
    final key = 'predicciones_p${pagina}_l${limite}_c${cargoId ?? 'all'}';
    try {
      final raw = await _service.fetchRaw(
        pagina: pagina,
        limite: limite,
        cargoId: cargoId,
      );
      final parsed = PredictionResponse.fromJson(raw);
      if (!parsed.success) {
        throw PredictionUnavailableException(
          parsed.mensaje.isNotEmpty
              ? parsed.mensaje
              : 'No fue posible obtener la predicción.',
        );
      }
      await _cache.write(key, raw);
      return PredictionResult(parsed);
    } on AppException catch (e) {
      if (e.isConnectivityIssue) {
        final entry = _cache.read(key);
        if (entry != null) {
          try {
            return PredictionResult(
              PredictionResponse.fromJson(entry.data),
              fromCache: true,
              cachedAt: entry.savedAt,
            );
          } catch (_) {
            /* caché inválida: se propaga el error original */
          }
        }
      }
      rethrow;
    } catch (_) {
      // json_serializable lanza TypeError/CastError si el JSON no cumple el contrato.
      throw const ParseException();
    }
  }
}
