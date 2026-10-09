import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../view_models/prediction_view_model.dart';
import 'buttons.dart';
import 'offline_banner.dart';
import 'section_card.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.text, this.background, this.foreground});

  final String text;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: background ?? AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.mono(size: 10.5, color: fg, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Texts extends StatelessWidget {
  const _Texts({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.5, height: 1.45, color: AppColors.textSecondary)),
        ],
      );
}

/// 404 / sin resultados de búsqueda.
class NotFoundState extends StatelessWidget {
  const NotFoundState({super.key, required this.onBackToOverview});
  final VoidCallback onBackToOverview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                    color: AppColors.chip.withValues(alpha: .7),
                    borderRadius: BorderRadius.circular(24)),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withValues(alpha: .15),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(Icons.manage_search, size: 42, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const _Texts(
                title: 'No encontramos este cargo',
                message:
                    'No hay registros históricos o modelos de predicción entrenados para el término ingresado. Intenta con otra denominación o explora los perfiles sugeridos.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SecondaryButton(
          label: 'Volver a la vista general',
          icon: Icons.grid_view_rounded,
          onPressed: onBackToOverview,
        ),
      ],
    );
  }
}

/// Error 5xx.
class ServerErrorState extends StatelessWidget {
  const ServerErrorState({super.key, required this.onRetry, this.onBack, this.code});
  final VoidCallback onRetry;
  final VoidCallback? onBack;
  final int? code;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatusPill(text: 'ERROR ${code ?? 500} • SERVIDOR DE INFERENCIA'),
        const SizedBox(height: 20),
        Container(
          height: 210,
          width: double.infinity,
          decoration: BoxDecoration(
              color: AppColors.chip.withValues(alpha: .6),
              borderRadius: BorderRadius.circular(24)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.dns_rounded, size: 84, color: AppColors.primary),
              Positioned(
                top: 54,
                right: 96,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      color: AppColors.dangerSoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.priority_high, size: 20, color: AppColors.danger),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _Texts(
          title: 'No pudimos generar la predicción',
          message:
              'Ocurrió un problema inesperado al procesar la información en nuestro clúster de inferencia de machine learning. El incidente ya ha sido registrado automáticamente por nuestro equipo de ingeniería.',
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Intentar nuevamente', icon: Icons.sync, onPressed: onRetry),
        if (onBack != null) ...[
          const SizedBox(height: 10),
          SecondaryButton(label: 'Volver atrás', icon: Icons.arrow_back, onPressed: onBack),
        ],
      ],
    );
  }
}

/// Sin red y sin caché.
class NoConnectionState extends StatelessWidget {
  const NoConnectionState({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OfflineBanner(),
        const SizedBox(height: 20),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: .12),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 60, color: AppColors.textMuted),
            ),
            Positioned(
              right: -10,
              bottom: -10,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3)),
                child: const Icon(Icons.wifi_off_rounded, size: 19, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const _Texts(
          title: 'Sin conexión a Internet',
          message:
              'No pudimos conectarnos con el servicio de predicción de SearchJobs. Verifica tu conexión Wi-Fi o datos móviles para continuar explorando las proyecciones laborales.',
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Reintentar conexión', icon: Icons.sync, onPressed: onRetry),
      ],
    );
  }
}

/// 400 (parámetros inválidos) y 422 (predicción no disponible): mensaje informativo
/// con el detalle que envía el backend.
class InfoState extends StatelessWidget {
  const InfoState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          child: Column(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                    color: AppColors.chip.withValues(alpha: .7),
                    borderRadius: BorderRadius.circular(22)),
                child: Icon(icon, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              _Texts(title: title, message: message),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Intentar nuevamente', icon: Icons.sync, onPressed: onRetry),
      ],
    );
  }
}

/// Elige la pantalla de error adecuada según el [ViewStatus].
class PredictionErrorBody extends StatelessWidget {
  const PredictionErrorBody({
    super.key,
    required this.status,
    required this.onRetry,
    this.errorCode,
    this.message,
    this.onBack,
  });

  final ViewStatus status;
  final VoidCallback onRetry;
  final int? errorCode;
  final String? message;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (status) {
      ViewStatus.offline => NoConnectionState(onRetry: onRetry),
      ViewStatus.notFound => NotFoundState(onBackToOverview: onRetry),
      ViewStatus.unavailable => InfoState(
          icon: Icons.insights,
          title: 'Predicción no disponible',
          message: message ??
              'No existen datos suficientes para realizar la predicción.',
          onRetry: onRetry,
        ),
      ViewStatus.invalidRequest => InfoState(
          icon: Icons.rule,
          title: 'Parámetros no válidos',
          message: message ?? 'Los parámetros enviados no son válidos.',
          onRetry: onRetry,
        ),
      _ => ServerErrorState(onRetry: onRetry, onBack: onBack, code: errorCode),
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: child,
    );
  }
}
