import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/cargo.dart';

/// Ranking horizontal "Top cargos mayor demanda".
class TopJobsBarList extends StatelessWidget {
  const TopJobsBarList({super.key, required this.items, this.startRank = 1});

  final List<Cargo> items;

  /// Posición del primer cargo (en la página 2 con límite 5 sería 6).
  final int startRank;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final maxValue = items.map((c) => c.vacantesProyectadas).reduce((a, b) => a > b ? a : b);
    final roof = ((maxValue / 250).ceil() * 250).clamp(250, 1000000).toDouble();

    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _Row(
              rank: startRank + i,
              cargo: items[i],
              fraction: items[i].vacantesProyectadas / roof,
              color: AppColors.seriesColor(i),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final f in [0, .25, .5, .75, 1.0])
              Text(f == 1.0 ? '${formatThousands(roof)} vacantes' : formatThousands(roof * f),
                  style: AppTextStyles.mono(size: 9, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.rank, required this.cargo, required this.fraction, required this.color});

  final int rank;
  final Cargo cargo;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.chip, shape: BoxShape.circle),
              child: Text('$rank',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(cargo.nombre.isNotEmpty ? cargo.nombre : cargo.etiqueta,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    Container(height: 12, color: AppColors.chip.withValues(alpha: .6)),
                    FractionallySizedBox(
                      widthFactor: fraction.clamp(0.02, 1.0),
                      child: Container(height: 12, color: color),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 62,
              child: Text('${cargo.vacantesProyectadas} vac.',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.mono(
                      size: 12, color: AppColors.textPrimary, weight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }
}
