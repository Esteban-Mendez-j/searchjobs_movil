import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Cabecera de las vistas. Con [onBack] muestra flecha (pantallas de estado);
/// sin ella muestra el logo de SearchJobs.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showBell = true,
    this.actions = const [],
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBell;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: AppColors.primary.withValues(alpha: .15),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 68,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (onBack != null)
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Volver',
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.trending_up, color: Colors.white),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (onBack == null)
                        Text('SEARCHJOBS',
                            style: AppTextStyles.mono(
                                size: 10,
                                color: AppColors.accent,
                                weight: FontWeight.w700)),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                if (showBell && onBack == null) const _Bell(),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bell extends StatelessWidget {
  const _Bell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notificaciones',
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}
