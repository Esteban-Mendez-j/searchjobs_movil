import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/buttons.dart';
import '../widgets/section_card.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthViewModel>().login(_email.text, _password.text);
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.field.withValues(alpha: .7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Iniciar Sesión',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.work_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('Bienvenido de nuevo',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Accede al análisis predictivo de tu carrera profesional.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                SectionCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Correo electrónico',
                            style: AppTextStyles.mono(
                                size: 12, color: AppColors.textPrimary, weight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => vm.clearError(),
                          decoration: _decoration('ejemplo@correo.com', Icons.mail_outline),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Ingresa tu correo';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                              return 'Correo no válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('Contraseña',
                            style: AppTextStyles.mono(
                                size: 12, color: AppColors.textPrimary, weight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          onChanged: (_) => vm.clearError(),
                          decoration: _decoration(
                            '••••••••',
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.length < 4) ? 'Mínimo 4 caracteres' : null,
                        ),
                        if (vm.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(vm.errorMessage!,
                              style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                        ],
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Iniciar Sesión',
                          icon: Icons.arrow_forward,
                          loading: vm.isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('¿No tienes una cuenta aún? '),
                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('El registro estará disponible pronto.'))),
                      child: const Text('Regístrate gratis',
                          style: TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
