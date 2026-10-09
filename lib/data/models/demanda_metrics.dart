import 'demanda_periodo.dart';

/// Valores derivados compartidos por Cargo y Requisito.
mixin DemandaMetrics {
  List<DemandaHistorica> get demandaHistorica;
  List<PrediccionPeriodo> get prediccion;
  double get crecimientoEstimado;

  DemandaHistorica? get _ultimoHistorico => demandaHistorica.isEmpty
      ? null
      : demandaHistorica.reduce((a, b) => a.periodo >= b.periodo ? a : b);

  PrediccionPeriodo? get prediccionFinal => prediccion.isEmpty
      ? null
      : prediccion.reduce((a, b) => a.periodo >= b.periodo ? a : b);

  /// Último año con datos históricos (ej. 2026).
  int get anioActual => _ultimoHistorico?.periodo ?? 0;

  /// Año de la predicción (ej. 2027).
  int get anioFuturo => prediccionFinal?.periodo ?? 0;

  /// Demanda observada en el último periodo histórico.
  int get demandaActual => _ultimoHistorico?.cantidad.round() ?? 0;

  /// Demanda predicha para el periodo futuro.
  int get demandaFutura => prediccionFinal?.cantidadPredicha.round() ?? 0;

  int get vacantesProyectadas => demandaFutura;

  double get crecimiento => crecimientoEstimado;

  /// Semi-amplitud del intervalo de predicción en % (el "±" del gráfico).
  double get confianza {
    final p = prediccionFinal;
    if (p == null || p.limiteInferior == null || p.limiteSuperior == null) return 0;
    if (p.cantidadPredicha <= 0) return 0;
    return ((p.limiteSuperior! - p.limiteInferior!) / 2) / p.cantidadPredicha * 100;
  }
}
