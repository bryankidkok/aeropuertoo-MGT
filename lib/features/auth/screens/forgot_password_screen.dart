import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/models/result_state.dart';
import '../../../shared/widgets/gradient_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.sendPasswordReset(_emailController.text.trim());
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                '¿Olvidaste tu contraseña?',
                style: GoogleFonts.rajdhani(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa tu email y te enviaremos un enlace para restablecerla.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.gray,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'tu@email.com',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.gray),
                ),
                style: const TextStyle(color: AppColors.white),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email requerido';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.state is Error && !_sent) {
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
                  if (_sent) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Correo enviado. Revisa tu bandeja de entrada.',
                        style: GoogleFonts.inter(
                          color: AppColors.chipGreen,
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
                    label: _sent ? 'ENVIAR OTRO' : 'ENVIAR ENLACE',
                    isLoading: loading,
                    onPressed: loading ? null : _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
