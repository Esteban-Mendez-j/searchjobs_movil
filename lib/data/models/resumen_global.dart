import 'cargo.dart';
import 'prediction_response.dart';

/// Indicadores globales calculados en el cliente a partir de la página
/// de cargos recibida (el contrato no trae un bloque "resumen").
class ResumenGlobal {
  const ResumenGlobal({
    required this.cargosAnalizados,
    required this.rango,
    required this.crecimientoGlobal,
    required this.liderNombre,
    required this.liderCrecimiento,
    required this.promedioPonderado,
    required this.totalVacantes,
  });

  final int cargosAnalizados;
  final String rango;
  final double crecimientoGlobal;
  final String liderNombre;
  final double liderCrecimiento;
  final double promedioPonderado;
  final int totalVacantes;

  factory ResumenGlobal.fromResponse(PredictionResponse r) {
    final cargos = r.cargos;
    final fin = r.horizontePrediccion.fin;

    if (cargos.isEmpty) {
      return ResumenGlobal(
        cargosAnalizados: r.paginacion.totalCargos,
        rango: '${fin - 3}-$fin',
        crecimientoGlobal: 0,
        liderNombre: '-',
        liderCrecimiento: 0,
        promedioPonderado: 0,
        totalVacantes: 0,
      );
    }

    final lider = cargos.reduce((a, b) => a.demandaFutura >= b.demandaFutura ? a : b);
    final total = cargos.fold<int>(0, (s, c) => s + c.demandaFutura);
    final promedio = cargos.fold<double>(0, (s, c) => s + c.crecimiento) / cargos.length;
    final ponderado = total == 0
        ? 0.0
        : cargos.fold<double>(0, (s, c) => s + c.crecimiento * c.demandaFutura) / total;

    final anios = cargos
        .expand((Cargo c) => c.demandaHistorica.map((h) => h.periodo))
        .toList();
    final inicio = anios.isEmpty ? fin - 3 : anios.reduce((a, b) => a < b ? a : b);

    return ResumenGlobal(
      cargosAnalizados: r.paginacion.totalCargos,
      rango: '$inicio-$fin',
      crecimientoGlobal: promedio,
      liderNombre: lider.etiqueta,
      liderCrecimiento: lider.crecimiento,
      promedioPonderado: ponderado,
      totalVacantes: total,
    );
  }
}
