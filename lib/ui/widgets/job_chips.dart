import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/cargo.dart';

class JobChip extends StatelessWidget {
  const JobChip({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    this.showCheck = false,
  });

  final String label;
  final Color color;
  final bool selected;
  final bool showCheck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.chip : AppColors.chip.withValues(alpha: .4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheck) ...[
              Icon(selected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
            ],
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// Conjunto de chips. Multi-selección (checkbox) o selección única.
class JobChipsWrap extends StatelessWidget {
  const JobChipsWrap({
    super.key,
    required this.cargos,
    required this.isSelected,
    required this.onTap,
    this.multiSelect = true,
  });

  final List<Cargo> cargos;
  final bool Function(Cargo) isSelected;
  final void Function(Cargo) onTap;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < cargos.length; i++)
          JobChip(
            label: cargos[i].etiqueta,
            color: AppColors.seriesColor(i),
            selected: isSelected(cargos[i]),
            showCheck: multiSelect,
            onTap: () => onTap(cargos[i]),
          ),
      ],
    );
  }
}
