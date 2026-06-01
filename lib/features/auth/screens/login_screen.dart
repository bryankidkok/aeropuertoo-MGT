import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_routes.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/models/result_state.dart';
import '../../../shared/widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/airplane_silhouette.svg',
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                AppColors.cyan,
                BlendMode.srcIn,
              ),
            ).withOpacity(0.08),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        'AEROPUERTO',
                        style: GoogleFonts.rajdhani(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cyan,
                          letterSpacing: 4,
                        ),
                      ),
                      Text(
                        'MGT',
                        style: GoogleFonts.rajdhani(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistema de Gestión Aeroportuaria',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.gray,
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'usuario@aeropuerto.com',
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
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
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
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.register),
                          child: Text(
                            '¿No tienes cuenta? Regístrate',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.cyan,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.forgotPassword),
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.cyan,
                            ),
                          ),
                        ),
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
                            label: 'INICIAR SESIÓN',
                            isLoading: loading,
                            onPressed: loading ? null : _submit,
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _OpacityExtension on Widget {
  Widget withOpacity(double opacity) => Opacity(opacity: opacity, child: this);
}
