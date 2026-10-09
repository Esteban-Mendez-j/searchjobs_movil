import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/cargo.dart';

typedef ChartSeries = ({Cargo cargo, Color color});

/// Histórico (línea sólida) + proyección IA (línea punteada, zona sombreada).
class EvolutionLineChart extends StatelessWidget {
  const EvolutionLineChart({super.key, required this.series, required this.forecastStartYear});

  final List<ChartSeries> series;
  final int forecastStartYear;

  @override
  Widget build(BuildContext context) {
    final bars = <LineChartBarData>[];
    var maxY = 0.0;
    var minX = double.infinity;
    var maxX = 0.0;

    for (final s in series) {
      final hist = s.cargo.demandaHistorica
          .map((p) => FlSpot(p.periodo.toDouble(), p.cantidad))
          .toList();
      final proj = s.cargo.prediccion
          .map((p) => FlSpot(p.periodo.toDouble(), p.cantidadPredicha))
          .toList();
      for (final sp in [...hist, ...proj]) {
        if (sp.y > maxY) maxY = sp.y;
        if (sp.x < minX) minX = sp.x;
        if (sp.x > maxX) maxX = sp.x;
      }
      if (hist.isNotEmpty) {
        bars.add(LineChartBarData(
          spots: hist,
          color: s.color,
          barWidth: 2.5,
          isCurved: false,
          dotData: const FlDotData(show: true),
        ));
      }
      final projSpots = [if (hist.isNotEmpty) hist.last, ...proj];
      if (projSpots.length > 1) {
        bars.add(LineChartBarData(
          spots: projSpots,
          color: s.color,
          barWidth: 2,
          isCurved: false,
          dashArray: [5, 4],
          dotData: const FlDotData(show: true),
        ));
      }
    }

    if (bars.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Sin datos para graficar')),
      );
    }

    final axis = niceAxis(maxY);
    final roof = axis.roof;
    final interval = axis.interval;

    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: 0,
              maxY: roof,
              lineBarsData: bars,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: AppColors.grid, strokeWidth: 1),
              ),
              rangeAnnotations: RangeAnnotations(
                verticalRangeAnnotations: [
                  VerticalRangeAnnotation(
                    x1: forecastStartYear.toDouble(),
                    x2: maxX,
                    color: AppColors.chip.withValues(alpha: .6),
                  ),
                ],
              ),
              extraLinesData: ExtraLinesData(
                verticalLines: [
                  VerticalLine(
                    x: forecastStartYear.toDouble(),
                    color: AppColors.accent,
                    strokeWidth: 1,
                    dashArray: [3, 3],
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 38,
                    interval: interval,
                    getTitlesWidget: (v, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(formatCompact(v),
                          style: AppTextStyles.mono(size: 10, color: AppColors.textSecondary)),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (v, meta) {
                      if (v != v.roundToDouble()) return const SizedBox.shrink();
                      final isForecast = v >= forecastStartYear + 1;
                      return SideTitleWidget(
                        meta: meta,
                        child: Text('${v.toInt()}',
                            style: AppTextStyles.mono(
                                size: 11,
                                color: isForecast ? AppColors.primary : AppColors.textSecondary,
                                weight: isForecast ? FontWeight.w800 : FontWeight.w500)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.primaryDark, borderRadius: BorderRadius.circular(4)),
              child: Text('PREDICCIÓN IA',
                  style: AppTextStyles.mono(size: 9, color: Colors.white, weight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
