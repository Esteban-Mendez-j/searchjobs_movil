import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/requisito.dart';

/// Gráfico de radar (araña) de requisitos: demanda actual vs. demanda proyectada.
///
/// - Siempre se dibuja: un radar necesita mínimo 3 ejes, así que si el cargo tiene
///   menos requisitos se completan con ejes vacíos (valor 0, sin etiqueta).
/// - Al tocar un punto del radar aparece un tooltip con la demanda actual y la
///   demanda futura de ese requisito.
class SkillsRadarChart extends StatefulWidget {
  const SkillsRadarChart({super.key, required this.requisitos});

  final List<Requisito> requisitos;

  @override
  State<SkillsRadarChart> createState() => _SkillsRadarChartState();
}

class _SkillsRadarChartState extends State<SkillsRadarChart> {
  static const _minAxes = 3;
  int? _touched;

  @override
  void didUpdateWidget(covariant SkillsRadarChart old) {
    super.didUpdateWidget(old);
    if (!identical(old.requisitos, widget.requisitos)) _touched = null;
  }

  void _onTouch(FlTouchEvent event, RadarTouchResponse? response) {
    final idx = response?.touchedSpot?.touchedRadarEntryIndex;
    if (event.isInterestedForInteractions &&
        idx != null &&
        idx < widget.requisitos.length) {
      if (_touched != idx) setState(() => _touched = idx);
    } else if (event is FlTapUpEvent && idx == null && _touched != null) {
      setState(() => _touched = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requisitos = widget.requisitos;
    final axes = <Requisito?>[...requisitos];
    while (axes.length < _minAxes) {
      axes.add(null);
    }

    double actual(Requisito? r) => (r?.demandaActual ?? 0).toDouble();
    double futura(Requisito? r) => (r?.demandaFutura ?? 0).toDouble();

    var maxValue = 0.0;
    for (final r in axes) {
      if (actual(r) > maxValue) maxValue = actual(r);
      if (futura(r) > maxValue) maxValue = futura(r);
    }
    if (maxValue <= 0) maxValue = 1;

    const gridSide = BorderSide(color: Color(0x334F46E5), width: 1);
    final selected = (_touched != null && _touched! < requisitos.length)
        ? requisitos[_touched!]
        : null;

    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              height: 290,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 3,
                  ticksTextStyle:
                      const TextStyle(color: Colors.transparent, fontSize: 8),
                  tickBorderData: gridSide,
                  gridBorderData: gridSide,
                  radarBorderData: gridSide,
                  borderData: FlBorderData(show: false),
                  titlePositionPercentageOffset: 0.14,
                  titleTextStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                  getTitle: (index, angle) =>
                      RadarChartTitle(text: axes[index]?.nombre ?? ''),
                  radarTouchData: RadarTouchData(
                    enabled: true,
                    touchSpotThreshold: 30,
                    touchCallback: _onTouch,
                  ),
                  dataSets: [
                    // Serie invisible que fija la escala del radar.
                    RadarDataSet(
                      fillColor: Colors.transparent,
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      entryRadius: 0,
                      dataEntries: [
                        for (final _ in axes) RadarEntry(value: maxValue)
                      ],
                    ),
                    // Demanda actual
                    RadarDataSet(
                      fillColor: AppColors.textMuted.withValues(alpha: .18),
                      borderColor: AppColors.textSecondary,
                      borderWidth: 1.5,
                      entryRadius: 2.5,
                      dataEntries: [
                        for (final r in axes) RadarEntry(value: actual(r))
                      ],
                    ),
                    // Demanda futura
                    RadarDataSet(
                      fillColor: AppColors.accent.withValues(alpha: .35),
                      borderColor: AppColors.accent,
                      borderWidth: 2.5,
                      entryRadius: 3.5,
                      dataEntries: [
                        for (final r in axes) RadarEntry(value: futura(r))
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (selected != null)
              Positioned(
                top: 0,
                child: _RadarTooltip(
                  requisito: selected,
                  onClose: () => setState(() => _touched = null),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            requisitos.isEmpty
                ? 'Este cargo no tiene requisitos asociados'
                : 'Toca un punto del radar para ver la demanda actual y futura',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _RadarTooltip extends StatelessWidget {
  const _RadarTooltip({required this.requisito, required this.onClose});

  final Requisito requisito;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final r = requisito;
    final anioActual = r.anioActual > 0 ? '${r.anioActual}' : 'actual';
    final anioFuturo = r.anioFuturo > 0 ? '${r.anioFuturo}' : 'futura';

    return GestureDetector(
      onTap: onClose,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.chip),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(r.nombre,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                ),
                if (r.tipo.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(r.tipo,
                      style: AppTextStyles.mono(
                          size: 9, color: AppColors.textMuted)),
                ],
                const SizedBox(width: 6),
                const Icon(Icons.close, size: 14, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 8),
            _TipRow(
              color: AppColors.textSecondary,
              label: 'Demanda actual ($anioActual)',
              value: formatThousands(r.demandaActual),
            ),
            const SizedBox(height: 4),
            _TipRow(
              color: AppColors.accent,
              label: 'Demanda futura ($anioFuturo)',
              value: formatThousands(r.demandaFutura),
              bold: true,
            ),
            const SizedBox(height: 6),
            Text('Crecimiento estimado ${formatPercent(r.crecimiento, decimals: 2)}',
                style: AppTextStyles.mono(
                    size: 10, color: AppColors.primary, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow(
      {required this.color,
      required this.label,
      required this.value,
      this.bold = false});

  final Color color;
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 10),
          Text(value,
              style: AppTextStyles.mono(
                  size: 12,
                  color: AppColors.textPrimary,
                  weight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      );
}
