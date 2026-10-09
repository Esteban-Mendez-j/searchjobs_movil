import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/requisito.dart';
import '../view_models/prediction_view_model.dart';
import 'evolution_line_chart.dart';
import 'job_chips.dart';
import 'section_card.dart';
import 'skills_radar_chart.dart';

/// Tarjeta "Top 5 cargos — evolución": KPIs, gráfico de líneas, leyenda y chips.
class EvolutionCard extends StatelessWidget {
  const EvolutionCard({super.key, required this.vm});
  final PredictionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final cargos = vm.evolutionCargos;
    final resumen = vm.resumen!;
    final lider = vm.leaderVisible;

    final series = <ChartSeries>[
      for (var i = 0; i < cargos.length; i++)
        if (vm.selectedLineIds.contains(cargos[i].cargoId))
          (cargo: cargos[i], color: AppColors.seriesColor(i)),
    ];

    final confianza = cargos.isEmpty
        ? 0.0
        : cargos.fold<double>(0, (s, c) => s + c.confianza) / cargos.length;

    return SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    cargos.length >= 2
                        ? 'Top ${cargos.length} cargos — evolución'
                        : 'Evolución del cargo',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Histórico (2024–${vm.currentYear}) vs. Proyección IA (${vm.forecastYear})',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Kpi(
                        label: 'Crecimiento estimado ${vm.forecastYear}',
                        value: formatPercent(resumen.crecimientoGlobal),
                        suffix: 'Global',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Kpi(
                        label: 'Líder proyectado',
                        value: lider?.etiqueta ?? '-',
                        suffix: '(${formatPercent(lider?.crecimiento ?? 0, decimals: 0)})',
                        small: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                EvolutionLineChart(series: series, forecastStartYear: vm.currentYear),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const _LegendLine(dashed: false),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text('Histórico consolidado',
                            style: AppTextStyles.mono(size: 10.5))),
                    const _LegendLine(dashed: true),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Proyección ±${confianza.toStringAsFixed(1)}% conf.',
                          style: AppTextStyles.mono(size: 10.5, color: AppColors.accent)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                JobChipsWrap(
                  cargos: cargos,
                  isSelected: (c) => vm.selectedLineIds.contains(c.cargoId),
                  onTap: (c) => vm.toggleLine(c.cargoId),
                ),
              ],
            ),
          );
  }
}

/// Tarjeta "Requisitos de un cargo" con el gráfico de radar (araña).
class RadarCard extends StatelessWidget {
  const RadarCard({required this.vm});
  final PredictionViewModel vm;

  @override
  Widget build(BuildContext context) {
    final cargo = vm.radarCargo;
    final reqs = cargo?.requisitos ?? const <Requisito>[];
    double avg(num Function(Requisito) f) =>
        reqs.isEmpty ? 0 : reqs.fold<double>(0, (s, r) => s + f(r).toDouble()) / reqs.length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Requisitos de un cargo',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SkillsRadarChart(requisitos: reqs),
          const SizedBox(height: 8),
          _AvgRow(
              color: AppColors.textSecondary,
              label: 'Demanda actual (${vm.currentYear})',
              value: avg((r) => r.demandaActual)),
          const SizedBox(height: 6),
          _AvgRow(
              color: AppColors.accent,
              label: 'Demanda proyectada (${vm.forecastYear})',
              value: avg((r) => r.demandaFutura),
              highlight: true),
          const SizedBox(height: 14),
          JobChipsWrap(
            cargos: vm.evolutionCargos,
            multiSelect: false,
            isSelected: (c) => c.cargoId == cargo?.cargoId,
            onTap: (c) => vm.selectRadar(c.cargoId),
          ),
        ],
      ),
    );
  }
}

class _AvgRow extends StatelessWidget {
  const _AvgRow(
      {required this.color, required this.label, required this.value, this.highlight = false});

  final Color color;
  final String label;
  final double value;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 16,
              height: 5,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
                    color: highlight ? AppColors.primary : AppColors.textSecondary)),
          ),
          Text('Promedio ${value.round()}',
              style: AppTextStyles.mono(
                  size: 12, color: AppColors.textPrimary, weight: FontWeight.w700)),
        ],
      );
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, required this.suffix, this.small = false});

  final String label;
  final String value;
  final String suffix;
  final bool small;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.field.withValues(alpha: .6), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.mono(size: 10.5)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: small ? 13 : 22,
                          fontWeight: FontWeight.w800,
                          color: small ? AppColors.primary : AppColors.textPrimary)),
                ),
                const SizedBox(width: 4),
                Text(suffix,
                    style: AppTextStyles.mono(
                        size: 10.5, color: AppColors.accent, weight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      );
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({required this.dashed});
  final bool dashed;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < (dashed ? 3 : 1); i++) ...[
            Container(
                width: dashed ? 5 : 20,
                height: 2.5,
                color: dashed ? AppColors.accent : AppColors.primaryDark),
            if (dashed) const SizedBox(width: 2),
          ],
        ],
      );
}
