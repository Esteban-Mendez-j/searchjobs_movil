import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text('Análisis Predictivo • Modo Offline',
                style: AppTextStyles.mono(
                    size: 11, color: AppColors.primary, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
