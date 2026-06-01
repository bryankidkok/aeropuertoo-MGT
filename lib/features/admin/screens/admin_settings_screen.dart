import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/result_state.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    final provider = context.read<AdminProvider>();
    provider.fetchAllUsers();
    provider.fetchAllFlights();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final provider = context.read<AdminProvider>();
    final counts = await provider.loadDashboardCounts();
    if (mounted) setState(() => _counts = counts);
  }

  Future<void> _showCreateUserDialog() async {
    final provider = context.read<AdminProvider>();
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    var role = UserRole.passenger;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text(
                'CREAR USUARIO',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email'),
                        style: const TextStyle(color: AppColors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Contrase\u00F1a',
                        ),
                        style: const TextStyle(color: AppColors.white),
                        obscureText: true,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        style: const TextStyle(color: AppColors.white),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<UserRole>(
                        initialValue: role,
                        decoration: const InputDecoration(labelText: 'Rol'),
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.white),
                        items: UserRole.values
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(r.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => role = v);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                  ),
                  child: const Text(
                    'CREAR',
                    style: TextStyle(color: AppColors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      await provider.createUser(
        emailCtrl.text.trim(),
        passCtrl.text,
        nameCtrl.text.trim(),
        role,
      );
    }

    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('CONFIGURACI\u00D3N DEL SISTEMA')),
      body: Consumer<AdminProvider>(
        builder: (ctx, provider, _) {
          final usersState = provider.usersState;
          final flightsState = provider.flightsState;

          int totalUsers = switch (usersState) {
            Success(data: final d) => d.length,
            _ => 0,
          };

          int totalFlights = switch (flightsState) {
            Success(data: final d) => d.length,
            _ => 0,
          };

          final totalBookings = _counts['bookings'] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('USUARIOS'),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _showCreateUserDialog,
                icon: const Icon(Icons.person_add, color: AppColors.cyan),
                label: const Text('CREAR USUARIO'),
              ),
              const SizedBox(height: 12),
              switch (usersState) {
                Loading() => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                Error(message: final msg) => Center(
                  child: Text(
                    msg,
                    style: const TextStyle(color: AppColors.chipRed),
                  ),
                ),
                Success(data: []) => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No hay usuarios',
                      style: TextStyle(color: AppColors.gray),
                    ),
                  ),
                ),
                Success(data: final users) => Column(
                  children: users
                      .map((u) => _buildUserCard(u, provider))
                      .toList(),
                ),
                _ => const SizedBox.shrink(),
              },
              const SizedBox(height: 24),
              _sectionTitle('ESTAD\u00CDSTICAS DEL SISTEMA'),
              const SizedBox(height: 8),
              _buildStatCard('Total Usuarios', totalUsers, AppColors.cyan),
              _buildStatCard('Total Vuelos', totalFlights, AppColors.orange),
              _buildStatCard(
                'Total Reservas',
                totalBookings,
                AppColors.chipGreen,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.cyan,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildUserCard(UserModel user, AdminProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
                const SizedBox(height: 4),
                _roleBadge(user.role),
              ],
            ),
          ),
          DropdownButton<UserRole>(
            value: user.role,
            dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.white, fontSize: 13),
            underline: const SizedBox.shrink(),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.cyan),
            items: UserRole.values
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.name.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null && v != user.role) {
                provider.updateUserRole(user.uid, v);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(UserRole role) {
    Color color;
    switch (role) {
      case UserRole.admin:
        color = AppColors.chipRed;
      case UserRole.staff:
        color = AppColors.cyan;
      case UserRole.passenger:
        color = AppColors.chipGreen;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        role.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          Text(
            '$value',
            style: GoogleFonts.rajdhani(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
