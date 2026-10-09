import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/cargo.dart';

/// Barras agrupadas: demanda actual vs. predicción.
class DemandBarChart extends StatelessWidget {
  const DemandBarChart({
    super.key,
    required this.items,
    required this.currentYear,
    required this.forecastYear,
  });

  final List<Cargo> items;
  final int currentYear;
  final int forecastYear;

  static const _barAreaHeight = 110.0;
  static const _actualColor = Color(0xFF9AA5BC);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final maxV = items
        .map((c) => c.demandaActual > c.demandaFutura ? c.demandaActual : c.demandaFutura)
        .reduce((a, b) => a > b ? a : b);
    final roof = (maxV <= 0 ? 1 : maxV).toDouble();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: AppColors.background, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: _actualColor, label: '$currentYear (Actual)'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.accent, label: '$forecastYear (Pred.)'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _barAreaHeight + 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final c in items)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Bar(value: c.demandaActual, roof: roof, color: _actualColor),
                          const SizedBox(width: 3),
                          _Bar(value: c.demandaFutura, roof: roof, color: AppColors.accent),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(c.etiqueta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.mono(size: 9, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.roof, required this.color});

  final int value;
  final double roof;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final h = (value / roof * DemandBarChart._barAreaHeight).clamp(2.0, DemandBarChart._barAreaHeight);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value',
            style: AppTextStyles.mono(
                size: 8,
                color: color == AppColors.accent ? AppColors.primary : AppColors.textSecondary,
                weight: FontWeight.w700)),
        const SizedBox(height: 2),
        Container(
          width: 14,
          height: h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.mono(size: 11)),
        ],
      );
}
