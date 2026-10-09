import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/prediction_repository.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/prediction_view_model.dart';
import '../widgets/app_header.dart';
import '../widgets/buttons.dart';
import '../widgets/demand_bar_chart.dart';
import '../widgets/evolution_sections.dart';
import '../widgets/offline_banner.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/search_field.dart';
import '../widgets/section_card.dart';
import '../widgets/state_views.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_jobs_bar_list.dart';

/// Página única de Análisis Predictivo (resumen + evolución + requisitos).
/// Crea el PredictionViewModel y lanza la primera carga.
class AnalysisView extends StatelessWidget {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          PredictionViewModel(ctx.read<PredictionRepository>())..load(),
      child: const _AnalysisPage(),
    );
  }
}

class _AnalysisPage extends StatefulWidget {
  const _AnalysisPage();

  @override
  State<_AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<_AnalysisPage> {
  final _searchController = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _goToPage(PredictionViewModel vm, int page) async {
    await vm.goToPage(page);
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _title(ViewStatus s) => switch (s) {
    ViewStatus.notFound => 'Sin resultados',
    ViewStatus.serverError => 'Error Servidor',
    ViewStatus.offline => 'Sin Conexión',
    ViewStatus.unavailable => 'Predicción no disponible',
    ViewStatus.invalidRequest => 'Solicitud no válida',
    _ => 'Análisis Predictivo',
  };

  void _clearSearch(PredictionViewModel vm) {
    _searchController.clear();
    vm.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PredictionViewModel>();
    final status = vm.status;

    return Scaffold(
      appBar: AppHeader(
        title: _title(status),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.read<AuthViewModel>().logout(),
          ),
        ],
      ),
      body: SafeArea(child: _body(vm, status)),
    );
  }

  Widget _body(PredictionViewModel vm, ViewStatus status) {
    if (status == ViewStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (status.isErrorScreen) {
      return PredictionErrorBody(
        status: status,
        errorCode: vm.errorCode,
        message: vm.errorMessage,
        onRetry: vm.retry,
      );
    }

    final notFound = status == ViewStatus.notFound;

    return RefreshIndicator(
      onRefresh: vm.load,
      child: ListView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          if (vm.fromCache && !notFound) ...[
            const OfflineBanner(),
            const SizedBox(height: 16),
          ],
          const Text(
            'Análisis predictivo',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Descubre cómo evolucionará la demanda de los cargos laborales.',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          SearchField(
            controller: _searchController,
            onChanged: vm.onSearchChanged,
          ),
          if (vm.isSearchLoading || vm.isPageLoading) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(minHeight: 3),
          ],
          if (vm.searchLimited && !vm.isSearchLoading) ...[
            const SizedBox(height: 8),
            const Text(
              'La búsqueda solo cubre los cargos ya cargados (sin conexión o límite del servidor).',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
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
                label: 'Reintentar conexión',
                icon: Icons.sync,
                onPressed: vm.retry,
              ),
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
    final stats = vm.pageStats;

    return [
      // ---- Indicadores ----
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
                caption:
                    '↗${formatPercent(resumen.liderCrecimiento, decimals: 2)} proyectado',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // ---- Barras: top cargos ----
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top cargos mayor demanda',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              'Estimación al cierre de ${vm.forecastYear}',
              style: AppTextStyles.mono(size: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TopJobsBarList(items: top, startRank: vm.rankOffset + 1),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // ---- Barras agrupadas: actual vs futura ----
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demanda actual vs futura',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Comparativa ${vm.currentYear} (Actual) vs. ${vm.forecastYear} (Predicción)',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            DemandBarChart(
              items: top,
              currentYear: vm.currentYear,
              forecastYear: vm.forecastYear,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Promedio ponderado: ${formatPercent(stats.promedioPonderado)}',
                  style: AppTextStyles.mono(
                    size: 11,
                    color: AppColors.primary,
                    weight: FontWeight.w700,
                  ),
                ),
                Text(
                  'N=${formatThousands(stats.totalVacantes)} vacantes',
                  style: AppTextStyles.mono(
                    size: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // ---- Líneas: evolución Top 5 ----
      EvolutionCard(vm: vm),
      const SizedBox(height: 16),

      // ---- Radar: requisitos de un cargo ----
      RadarCard(vm: vm),
      const SizedBox(height: 20),

      // ---- Paginación (abajo) ----
      _pagination(vm),
    ];
  }

  Widget _pagination(PredictionViewModel vm) {
    return Column(
      children: [
        PaginationBar(
          currentPage: vm.currentPage,
          totalPages: vm.totalPages,
          totalItems: vm.totalItems,
          itemLabel: vm.isSearching ? 'resultados' : 'cargos',
          enabled: !vm.isPageLoading,
          onPageSelected: (p) => _goToPage(vm, p),
        ),
        if (vm.pageError != null) ...[
          const SizedBox(height: 8),
          Text(
            vm.pageError!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
