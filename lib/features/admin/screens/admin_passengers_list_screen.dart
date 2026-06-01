import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/passenger_model.dart';
import '../../../shared/models/result_state.dart';
import 'admin_passenger_form_dialog.dart';

class AdminPassengersListScreen extends StatefulWidget {
  const AdminPassengersListScreen({super.key});

  @override
  State<AdminPassengersListScreen> createState() => _AdminPassengersListScreenState();
}

class _AdminPassengersListScreenState extends State<AdminPassengersListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllPassengers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PassengerModel> _filter(List<PassengerModel> passengers) {
    if (_searchQuery.isEmpty) return passengers;
    final q = _searchQuery.toLowerCase();
    return passengers.where((p) {
      return p.firstName.toLowerCase().contains(q) ||
          p.lastName.toLowerCase().contains(q) ||
          p.email.toLowerCase().contains(q) ||
          p.passportNumber.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _deletePassenger(PassengerModel p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar Pasajero', style: TextStyle(color: AppColors.white)),
        content: Text(
          '¿Eliminar a ${p.fullName}?',
          style: const TextStyle(color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR', style: TextStyle(color: AppColors.gray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ELIMINAR', style: TextStyle(color: AppColors.chipRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    final ok = await context.read<AdminProvider>().deletePassenger(p.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Pasajero eliminado' : 'Error al eliminar'),
          backgroundColor: ok ? AppColors.chipGreen : AppColors.chipRed,
        ),
      );
    }
  }

  void _openForm({PassengerModel? passenger}) {
    showPassengerFormDialog(context, passenger: passenger);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PASAJEROS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.cyan),
            tooltip: 'AGREGAR',
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email o pasaporte...',
                prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.gray),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (_, provider, _) {
                final state = provider.passengersState;
                return switch (state) {
                  Loading() => const Center(child: CircularProgressIndicator()),
                  Error(message: final msg) => Center(
                      child: Text(msg, style: const TextStyle(color: AppColors.chipRed)),
                    ),
                  Success(data: final passengers) => _buildList(_filter(passengers)),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<PassengerModel> passengers) {
    if (passengers.isEmpty) {
      return const Center(
        child: Text('No se encontraron pasajeros', style: TextStyle(color: AppColors.gray)),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<AdminProvider>().fetchAllPassengers(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: passengers.length,
        itemBuilder: (_, i) => _buildCard(passengers[i]),
      ),
    );
  }

  Widget _buildCard(PassengerModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.fullName,
                  style: GoogleFonts.rajdhani(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              _statusChip(p.isActive),
            ],
          ),
          const SizedBox(height: 6),
          _infoRow(Icons.email_outlined, p.email),
          if (p.phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            _infoRow(Icons.phone_outlined, p.phone),
          ],
          _infoRow(Icons.credit_card_outlined, 'Pasaporte: ${p.passportNumber}'),
          if (p.frequentFlyerNumber != null && p.frequentFlyerNumber!.isNotEmpty) ...[
            const SizedBox(height: 2),
            _infoRow(Icons.card_membership, 'Viajero Frecuente: ${p.frequentFlyerNumber}'),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionButton(Icons.edit, AppColors.cyan, () => _openForm(passenger: p)),
              const SizedBox(width: 8),
              _actionButton(Icons.delete, AppColors.chipRed, () => _deletePassenger(p)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? AppColors.chipGreen.withValues(alpha: 0.15) : AppColors.chipRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: active ? AppColors.chipGreen.withValues(alpha: 0.5) : AppColors.chipRed.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        active ? 'ACTIVO' : 'INACTIVO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: active ? AppColors.chipGreen : AppColors.chipRed,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.gray),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.gray),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
