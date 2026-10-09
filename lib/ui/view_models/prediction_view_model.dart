import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/cargo.dart';
import '../../data/models/prediction_response.dart';
import '../../data/models/resumen_global.dart';
import '../../data/repositories/prediction_repository.dart';

/// Estados que la UI sabe pintar.
/// - notFound: 404 (sin datos) o búsqueda sin coincidencias
/// - invalidRequest: 400 (parámetros inválidos)
/// - unavailable: 422 (el modelo no puede predecir)
/// - serverError: 5xx / error inesperado
/// - offline: sin red y SIN caché
enum ViewStatus {
  loading,
  success,
  notFound,
  invalidRequest,
  unavailable,
  serverError,
  offline,
}

extension ViewStatusX on ViewStatus {
  /// Estados que se pintan como pantalla de error/información completa.
  bool get isErrorScreen =>
      this == ViewStatus.serverError ||
      this == ViewStatus.offline ||
      this == ViewStatus.unavailable ||
      this == ViewStatus.invalidRequest;
}

class PredictionViewModel extends ChangeNotifier {
  PredictionViewModel(this._repository);

  final PredictionRepository _repository;

  // ------------------------------------------------------------- estado
  ViewStatus _loadStatus = ViewStatus.loading;

  /// Página actual devuelta por el servidor.
  PredictionResponse? _data;

  /// Indicadores globales (se calculan con la página 1 y no cambian al paginar).
  ResumenGlobal? _resumen;

  /// Todos los cargos, cargados bajo demanda para poder buscar en todo el catálogo.
  List<Cargo>? _pool;

  bool _fromCache = false;
  DateTime? _cachedAt;
  String? _errorMessage;
  int? _errorCode;

  bool _pageLoading = false;
  String? _pageError;
  bool _searchLoading = false;

  String _query = '';
  int _searchPage = 0; // paginación local sobre los resultados de búsqueda
  Timer? _debounce;
  bool _disposed = false;

  Set<String> _lineIds = {};
  String _listKey = '';
  String? _radarId;

  // ------------------------------------------------------------- getters básicos
  ViewStatus get loadStatus => _loadStatus;

  /// Estado para la página (incluye "sin resultados" de búsqueda).
  ViewStatus get status {
    if (_loadStatus == ViewStatus.success &&
        isSearching &&
        !_searchLoading &&
        matches.isEmpty) {
      return ViewStatus.notFound;
    }
    return _loadStatus;
  }

  PredictionResponse? get data => _data;
  ResumenGlobal? get resumen => _resumen;
  bool get fromCache => _fromCache;
  DateTime? get cachedAt => _cachedAt;
  String? get errorMessage => _errorMessage;
  int? get errorCode => _errorCode;
  String get query => _query;

  bool get isPageLoading => _pageLoading;
  bool get isSearchLoading => _searchLoading;
  String? get pageError => _pageError;

  // ------------------------------------------------------------- búsqueda
  bool get isSearching => normalizeText(_query).isNotEmpty;

  List<Cargo> get allCargos => _data?.cargos ?? const [];

  List<Cargo> get _searchSource => _pool ?? allCargos;

  /// true si la búsqueda no pudo cubrir todo el catálogo (sin red / límite del backend).
  bool get searchLimited {
    final total = _data?.paginacion.totalCargos ?? 0;
    return isSearching && _searchSource.length < total;
  }

  /// Resultados de la búsqueda ordenados por demanda futura.
  List<Cargo> get matches {
    final q = normalizeText(_query);
    final list = _searchSource
        .where((c) =>
            normalizeText(c.nombre).contains(q) ||
            normalizeText(c.etiqueta).contains(q))
        .toList();
    list.sort((a, b) => b.demandaFutura.compareTo(a.demandaFutura));
    return list;
  }

  // ------------------------------------------------------------- paginación
  int get pageSize => AppConfig.defaultLimit;

  int get currentPage =>
      isSearching ? _searchPage + 1 : (_data?.paginacion.pagina ?? 1);

  int get totalPages {
    if (isSearching) {
      final n = (matches.length / pageSize).ceil();
      return n < 1 ? 1 : n;
    }
    final n = _data?.paginacion.totalPaginas ?? 1;
    return n < 1 ? 1 : n;
  }

  int get totalItems =>
      isSearching ? matches.length : (_data?.paginacion.totalCargos ?? 0);

  /// Posición del primer cargo visible (para numerar el ranking: 6, 7, 8…).
  int get rankOffset => (currentPage - 1) * pageSize;

  /// Cargos de la página visible, ordenados por demanda futura.
  List<Cargo> get pageCargos {
    final list = isSearching
        ? matches.skip(_searchPage * pageSize).take(pageSize).toList()
        : [...allCargos];
    list.sort((a, b) => b.demandaFutura.compareTo(a.demandaFutura));
    return list;
  }

  /// Los gráficos de barras, líneas y el radar usan los cargos de la página visible
  /// (que ya respetan la búsqueda).
  List<Cargo> get topCargos => pageCargos;
  List<Cargo> get evolutionCargos => pageCargos;

  /// Líder y promedios de los cargos que se están mostrando.
  Cargo? get leaderVisible => pageCargos.isEmpty ? null : pageCargos.first;

  ({double promedioPonderado, int totalVacantes}) get pageStats {
    final list = pageCargos;
    final total = list.fold<int>(0, (s, c) => s + c.demandaFutura);
    final weighted = total == 0
        ? 0.0
        : list.fold<double>(0, (s, c) => s + c.crecimiento * c.demandaFutura) /
            total;
    return (promedioPonderado: weighted, totalVacantes: total);
  }

  // ------------------------------------------------------------- años
  /// Año de la predicción (horizonte del contrato, ej. 2027).
  int get forecastYear => _data?.horizontePrediccion.fin ?? 2027;

  /// Último año con datos históricos (ej. 2026).
  int get currentYear {
    for (final c in [...evolutionCargos, ...allCargos]) {
      if (c.anioActual > 0) return c.anioActual;
    }
    return forecastYear - 1;
  }

  // ------------------------------------------------------------- selección
  Set<String> get selectedLineIds => _lineIds;
  String? get radarCargoId => _radarId;

  Cargo? get radarCargo {
    final list = evolutionCargos;
    for (final c in list) {
      if (c.cargoId == _radarId) return c;
    }
    return list.isEmpty ? null : list.first;
  }

  // ------------------------------------------------------------- acciones
  Future<void> load() async {
    if (_data == null) {
      _loadStatus = ViewStatus.loading;
      _notify();
    }
    try {
      final page = _data?.paginacion.pagina ?? AppConfig.defaultPage;
      final result = await _repository.getPredictions(pagina: page);
      _applyResult(result);
      _errorMessage = null;
      _errorCode = null;
      _loadStatus = ViewStatus.success;
      _pool = null; // se vuelve a cargar si hay búsqueda activa
      if (isSearching) await _ensurePool();
      _syncSelection();
    } on NotFoundException catch (e) {
      _setError(ViewStatus.notFound, e);
    } on ValidationException catch (e) {
      _setError(ViewStatus.invalidRequest, e);
    } on PredictionUnavailableException catch (e) {
      _setError(ViewStatus.unavailable, e);
    } on AppException catch (e) {
      if (_data != null) {
        // Ya hay datos en pantalla: se conservan y se marca modo offline.
        _fromCache = _fromCache || e.isConnectivityIssue;
        _errorMessage = e.message;
      } else if (e.isConnectivityIssue) {
        _setError(ViewStatus.offline, e);
      } else {
        _setError(ViewStatus.serverError, e);
      }
    } catch (_) {
      _setError(ViewStatus.serverError, const UnknownApiException());
    }
    _notify();
  }

  Future<void> retry() => load();

  /// Cambia de página. Sin búsqueda consulta al servidor (pagina=N);
  /// con búsqueda pagina localmente los resultados.
  Future<void> goToPage(int page) async {
    final target = page.clamp(1, totalPages);
    if (target == currentPage || _pageLoading) return;
    _pageError = null;

    if (isSearching) {
      _searchPage = target - 1;
      _syncSelection();
      _notify();
      return;
    }

    _pageLoading = true;
    _notify();
    try {
      final result = await _repository.getPredictions(pagina: target);
      _applyResult(result);
      _syncSelection();
    } on AppException catch (e) {
      _pageError = e.isConnectivityIssue
          ? 'Sin conexión: esta página aún no está guardada para verla offline.'
          : e.message;
    } catch (_) {
      _pageError = 'No se pudo cargar la página $target.';
    }
    _pageLoading = false;
    _notify();
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _applyQuery(value));
  }

  void clearSearch() {
    _debounce?.cancel();
    _query = '';
    _searchPage = 0;
    _pageError = null;
    _syncSelection();
    _notify();
  }

  void toggleLine(String id) {
    final next = {..._lineIds};
    if (!next.remove(id)) next.add(id);
    if (next.isEmpty) return; // siempre al menos una serie
    _lineIds = next;
    _notify();
  }

  void selectRadar(String id) {
    _radarId = id;
    _notify();
  }

  // ------------------------------------------------------------- privado
  Future<void> _applyQuery(String value) async {
    _query = value;
    _searchPage = 0;
    _pageError = null;
    if (isSearching) await _ensurePool();
    _syncSelection();
    _notify();
  }

  /// Carga todos los cargos (pagina=1, limite=total) para buscar en todo el catálogo.
  Future<void> _ensurePool() async {
    final current = _data;
    if (_pool != null || current == null) return;

    final total = current.paginacion.totalCargos;
    if (total <= current.cargos.length) {
      _pool = current.cargos;
      return;
    }

    _searchLoading = true;
    _notify();
    try {
      final result = await _repository.getPredictions(pagina: 1, limite: total);
      _pool = result.data.cargos;
    } catch (_) {
      // Sin red o el backend limita "limite": se busca solo en la página actual.
    }
    _searchLoading = false;
  }

  void _applyResult(PredictionResult result) {
    _data = result.data;
    _fromCache = result.fromCache;
    _cachedAt = result.cachedAt;
    if (_resumen == null || result.data.paginacion.pagina == 1) {
      _resumen = ResumenGlobal.fromResponse(result.data);
    }
  }

  void _setError(ViewStatus s, AppException e) {
    _loadStatus = s;
    _errorMessage = e.message;
    _errorCode = e.statusCode;
  }

  /// Mantiene coherentes los checkbox y el radar con la lista visible.
  void _syncSelection() {
    final list = evolutionCargos;
    final ids = list.map((c) => c.cargoId).toList();
    final key = ids.join(',');
    if (key != _listKey) {
      _listKey = key;
      _lineIds = ids.toSet(); // lista nueva: todos marcados
    }
    if (_radarId == null || !ids.contains(_radarId)) {
      _radarId = ids.isEmpty ? null : ids.first;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
