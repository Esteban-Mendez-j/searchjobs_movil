import '../../core/utils/json_utils.dart';

class SeriePoint {
  const SeriePoint({required this.anio, required this.valor});
  final int anio;
  final double valor;

  factory SeriePoint.fromJson(Map<String, dynamic> j) =>
      SeriePoint(anio: asInt(j['anio']), valor: asDouble(j['valor']));
}

class Requisito {
  const Requisito({
    required this.nombre,
    required this.nivelActual,
    required this.demandaProyectada,
  });

  final String nombre;
  final double nivelActual; // 0-100
  final double demandaProyectada; // 0-100

  factory Requisito.fromJson(Map<String, dynamic> j) => Requisito(
        nombre: asString(j['nombre']),
        nivelActual: asDouble(j['nivel_actual']),
        demandaProyectada: asDouble(j['demanda_proyectada']),
      );
}

class CargoPrediction {
  const CargoPrediction({
    required this.cargoId,
    required this.nombre,
    required this.nombreCorto,
    required this.vacantesProyectadas,
    required this.demandaActual,
    required this.demandaFutura,
    required this.crecimiento,
    required this.confianza,
    required this.historico,
    required this.proyeccion,
    required this.requisitos,
  });

  final String cargoId;
  final String nombre;
  final String nombreCorto;
  final int vacantesProyectadas;
  final int demandaActual;
  final int demandaFutura;
  final double crecimiento;
  final double confianza;
  final List<SeriePoint> historico;
  final List<SeriePoint> proyeccion;
  final List<Requisito> requisitos;

  String get etiqueta => nombreCorto.isNotEmpty ? nombreCorto : nombre;

  factory CargoPrediction.fromJson(Map<String, dynamic> j) {
    final futura = asInt(j['demanda_futura']);
    return CargoPrediction(
      cargoId: asString(j['cargo_id']),
      nombre: asString(j['nombre']),
      nombreCorto: asString(j['nombre_corto']),
      vacantesProyectadas: asInt(j['vacantes_proyectadas'], futura),
      demandaActual: asInt(j['demanda_actual']),
      demandaFutura: futura,
      crecimiento: asDouble(j['crecimiento']),
      confianza: asDouble(j['confianza']),
      historico: asMapList(j['historico']).map(SeriePoint.fromJson).toList(),
      proyeccion: asMapList(j['proyeccion']).map(SeriePoint.fromJson).toList(),
      requisitos: asMapList(j['requisitos']).map(Requisito.fromJson).toList(),
    );
  }
}
