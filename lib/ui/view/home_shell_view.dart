import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/prediction_repository.dart';
import '../view_models/prediction_view_model.dart';
import 'evolution_view.dart';
import 'summary_view.dart';

/// Contenedor autenticado: crea el PredictionViewModel (compartido por las
/// dos pestañas) y la navegación inferior.
class HomeShellView extends StatelessWidget {
  const HomeShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PredictionViewModel(ctx.read<PredictionRepository>())..load(),
      child: const _HomeScaffold(),
    );
  }
}

class _HomeScaffold extends StatefulWidget {
  const _HomeScaffold();

  @override
  State<_HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<_HomeScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [SummaryView(), EvolutionView()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Resumen'),
          NavigationDestination(
              icon: Icon(Icons.show_chart), selectedIcon: Icon(Icons.stacked_line_chart), label: 'Evolución'),
        ],
      ),
    );
  }
}
