import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/prediction_view_model.dart';
import '../widgets/app_header.dart';
import '../widgets/buttons.dart';
import '../widgets/demand_bar_chart.dart';
import '../widgets/offline_banner.dart';
import '../widgets/search_field.dart';
import '../widgets/section_card.dart';
import '../widgets/state_views.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_jobs_bar_list.dart';

class SummaryView extends StatefulWidget {
  const SummaryView({super.key});

  @override
  State<SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends State<SummaryView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _title(ViewStatus s) => switch (s) {
        ViewStatus.notFound => 'Sin resultados',
        ViewStatus.serverError => 'Error Servidor',
        ViewStatus.offline => 'Sin Conexión',
        ViewStatus.unavailable => 'Predicción no disponible',
        ViewStatus.invalidRequest => 'Solicitud no válida',
        _ => 'Análisis Predictivo — Resumen',
      };

  void _clearSearch(PredictionViewModel vm) {
    _searchController.clear();
    vm.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PredictionViewModel>();
    final status = vm.status;
    final isErrorScreen = status.isErrorScreen;

    return Scaffold(
      appBar: AppHeader(
        title: _title(status),
        onBack: isErrorScreen && Navigator.of(context).canPop()
            ? () => Navigator.of(context).pop()
            : null,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthViewModel>().logout(),
          ),
        ],
      ),
      body: SafeArea(child: _body(context, vm, status, isErrorScreen)),
    );
  }

  Widget _body(BuildContext context, PredictionViewModel vm, ViewStatus status, bool isError) {
    if (status == ViewStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isError) {
      return PredictionErrorBody(
        status: status,
        errorCode: vm.errorCode,
        message: vm.errorMessage,
        onRetry: vm.retry,
        onBack: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
      );
    }

    final notFound = status == ViewStatus.notFound;

    return RefreshIndicator(
      onRefresh: vm.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          if (vm.fromCache && !notFound) ...[const OfflineBanner(), const SizedBox(height: 16)],
          const Text('Análisis predictivo',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Descubre cómo evolucionará la demanda de los cargos laborales.',
              style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.textSecondary)),
          const SizedBox(height: 18),
          SearchField(controller: _searchController, onChanged: vm.onSearchChanged),
          const SizedBox(height: 16),
          if (notFound)
            NotFoundState(
              onBackToOverview: () {
                _clearSearch(vm);
                // 404 del servidor (sin datos cargados): reintenta la carga.
                if (vm.data == null) vm.retry();
              },
            )
          else ...[
            if (vm.fromCache) ...[
              PrimaryButton(
                  label: 'Reintentar conexión', icon: Icons.sync, onPressed: vm.retry),
              const SizedBox(height: 16),
            ],
            ..._content(vm),
          ],
        ],
      ),
    );
  }

  List<Widget> _content(PredictionViewModel vm) {
    final resumen = vm.resumen!;
    final top = vm.topCargos;

    return [
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.query_stats,
                badge: resumen.rango,
                headline: '${resumen.cargosAnalizados}',
                caption: 'Cargos analizados por el observatorio',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.trending_up,
                badge: 'Top #1',
                eyebrow: 'MAYOR DEMANDA',
                headline: resumen.liderNombre,
                headlineSize: 18,
                caption: '↗${formatPercent(resumen.liderCrecimiento, decimals: 2)} proyectado',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top cargos mayor demanda',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('Estimación al cierre de ${vm.forecastYear}',
                style: AppTextStyles.mono(size: 11, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TopJobsBarList(items: top),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Demanda actual vs futura',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Comparativa ${vm.currentYear} (Actual) vs. ${vm.forecastYear} (Predicción)',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            DemandBarChart(
                items: top, currentYear: vm.currentYear, forecastYear: vm.forecastYear),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Promedio ponderado: ${formatPercent(resumen.promedioPonderado)}',
                    style: AppTextStyles.mono(
                        size: 11, color: AppColors.primary, weight: FontWeight.w700)),
                Text('N=${formatThousands(resumen.totalVacantes)} vacantes',
                    style: AppTextStyles.mono(size: 11, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}
