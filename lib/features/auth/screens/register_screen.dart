import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_routes.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/models/result_state.dart';
import '../../../shared/widgets/gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'CREAR CUENTA',
                    style: GoogleFonts.rajdhani(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cyan,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Regístrate como pasajero',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.gray,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      hintText: 'Juan Pérez',
                      prefixIcon: Icon(Icons.person_outlined, color: AppColors.gray),
                    ),
                    style: const TextStyle(color: AppColors.white),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Nombre requerido';
                      if (v.trim().length < 2) return 'Mínimo 2 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'usuario@correo.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.gray),
                    ),
                    style: const TextStyle(color: AppColors.white),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email requerido';
                      if (!v.contains('@')) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.gray),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.gray,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.white),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Contraseña requerida';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.gray),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.gray,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    style: const TextStyle(color: AppColors.white),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirmar contraseña';
                      if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.state is Error) {
                        final err = (auth.state as Error).message;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            err,
                            style: GoogleFonts.inter(
                              color: AppColors.chipRed,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final loading = auth.state is Loading;
                      return GradientButton(
                        label: 'CREAR CUENTA',
                        isLoading: loading,
                        onPressed: loading ? null : _submit,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      '¿Ya tienes cuenta? Inicia sesión',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
