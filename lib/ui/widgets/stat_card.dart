import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'section_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.badge,
    required this.headline,
    required this.caption,
    this.eyebrow,
    this.headlineSize = 32,
  });

  final IconData icon;
  final String badge;
  final String headline;
  final String caption;
  final String? eyebrow;
  final double headlineSize;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: AppColors.chip, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.chip, borderRadius: BorderRadius.circular(12)),
                child: Text(badge,
                    style: AppTextStyles.mono(
                        size: 11, color: AppColors.primary, weight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (eyebrow != null)
            Text(eyebrow!,
                style: AppTextStyles.mono(
                    size: 10, color: AppColors.accent, weight: FontWeight.w700)),
          Text(headline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: headlineSize, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(caption,
              style: eyebrow == null
                  ? const TextStyle(fontSize: 12, color: AppColors.textSecondary)
                  : AppTextStyles.mono(size: 11, color: AppColors.accent)),
        ],
      ),
    );
  }
}
