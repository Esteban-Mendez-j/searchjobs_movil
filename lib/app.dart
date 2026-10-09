import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'ui/view/analysis_view.dart';
import 'ui/view/login_view.dart';
import 'ui/view_models/auth_view_model.dart';

class SearchJobsApp extends StatelessWidget {
  const SearchJobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SearchJobs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AuthGate(),
    );
  }
}

/// Decide la pantalla raíz según la sesión (JWT).
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthViewModel, AuthStatus>((vm) => vm.status);
    return switch (status) {
      AuthStatus.unknown => const Scaffold(body: Center(child: CircularProgressIndicator())),
      AuthStatus.authenticated => const AnalysisView(),
      AuthStatus.unauthenticated => const LoginView(),
    };
  }
}
