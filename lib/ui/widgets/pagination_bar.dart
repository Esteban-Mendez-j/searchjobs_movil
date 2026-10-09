import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Botones de paginación: « 1 … 4 [5] 6 … 24 ».
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageSelected,
    this.itemLabel = 'cargos',
    this.enabled = true,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String itemLabel;
  final bool enabled;
  final ValueChanged<int> onPageSelected;

  /// Páginas visibles; null = puntos suspensivos.
  List<int?> _pages() {
    final set = <int>{1, totalPages, currentPage - 1, currentPage, currentPage + 1}
      ..removeWhere((p) => p < 1 || p > totalPages);
    final sorted = set.toList()..sort();
    final out = <int?>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) out.add(null);
      out.add(sorted[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            _PageButton(
              icon: Icons.chevron_left,
              tooltip: 'Página anterior',
              onTap: enabled && currentPage > 1
                  ? () => onPageSelected(currentPage - 1)
                  : null,
            ),
            for (final p in _pages())
              if (p == null)
                const SizedBox(
                  width: 22,
                  child: Text('…',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted)),
                )
              else
                _PageButton(
                  label: '$p',
                  selected: p == currentPage,
                  onTap: enabled && p != currentPage ? () => onPageSelected(p) : null,
                ),
            _PageButton(
              icon: Icons.chevron_right,
              tooltip: 'Página siguiente',
              onTap: enabled && currentPage < totalPages
                  ? () => onPageSelected(currentPage + 1)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Página $currentPage de $totalPages · $totalItems $itemLabel',
            style: AppTextStyles.mono(size: 11, color: AppColors.textMuted)),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    this.label,
    this.icon,
    this.tooltip,
    this.selected = false,
    required this.onTap,
  });

  final String? label;
  final IconData? icon;
  final String? tooltip;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null && !selected;
    final child = Material(
      color: selected ? AppColors.primaryDark : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? AppColors.primaryDark : AppColors.chip),
          ),
          child: icon != null
              ? Icon(icon,
                  size: 22,
                  color: disabled ? AppColors.textMuted : AppColors.primary)
              : Text(label!,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.textPrimary)),
        ),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}
