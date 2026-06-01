import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/aircraft_model.dart';
import '../../../shared/models/result_state.dart';
import 'admin_aircraft_form_dialog.dart';

class AdminAircraftsListScreen extends StatefulWidget {
  const AdminAircraftsListScreen({super.key});

  @override
  State<AdminAircraftsListScreen> createState() =>
      _AdminAircraftsListScreenState();
}

class _AdminAircraftsListScreenState extends State<AdminAircraftsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllAircrafts();
      context.read<AdminProvider>().fetchAllAirlines();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AircraftModel> _filterAircrafts(List<AircraftModel> aircrafts) {
    if (_searchQuery.isEmpty) return aircrafts;
    final q = _searchQuery.toLowerCase();
    return aircrafts.where((a) {
      return a.model.toLowerCase().contains(q) ||
          a.registration.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _confirmDelete(AircraftModel aircraft) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('ELIMINAR AERONAVE',
            style: GoogleFonts.rajdhani(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
        content: Text(
          '¿Eliminar ${aircraft.registration} (${aircraft.model})?',
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
    if (confirmed == true && mounted) {
      await context.read<AdminProvider>().deleteAircraft(aircraft.id);
    }
  }

  void _openForm({AircraftModel? aircraft}) {
    showAircraftFormDialog(context, aircraft: aircraft);
  }

  Widget _buildStatusChip(AircraftStatus status) {
    Color color;
    String label;
    switch (status) {
      case AircraftStatus.active:
        color = AppColors.chipGreen;
        label = 'Activa';
      case AircraftStatus.maintenance:
        color = AppColors.chipYellow;
        label = 'Mantenimiento';
      case AircraftStatus.retired:
        color = AppColors.chipRed;
        label = 'Retirada';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AERONAVES'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add, color: AppColors.cyan, size: 20),
              label: Text('AGREGAR',
                  style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cyan)),
            ),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          final state = provider.aircraftsState;

          if (state is Loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is Error<List<AircraftModel>>) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.chipRed, size: 48),
                  const SizedBox(height: 12),
                  Text((state).message,
                      style: const TextStyle(color: AppColors.gray)),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: provider.fetchAllAircrafts,
                    icon: const Icon(Icons.refresh, color: AppColors.cyan),
                    label: const Text('REINTENTAR',
                        style: TextStyle(color: AppColors.cyan)),
                  ),
                ],
              ),
            );
          }

          if (state is! Success<List<AircraftModel>>) {
            return const SizedBox.shrink();
          }

          final aircrafts = _filterAircrafts(state.data);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por modelo o matrícula...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.gray),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.gray, size: 18),
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
                child: aircrafts.isEmpty
                    ? const Center(
                        child: Text('No se encontraron aeronaves',
                            style: TextStyle(color: AppColors.gray)))
                    : RefreshIndicator(
                        onRefresh: provider.fetchAllAircrafts,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: aircrafts.length,
                          itemBuilder: (_, i) =>
                              _buildAircraftCard(aircrafts[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAircraftCard(AircraftModel aircraft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
                child: Text(aircraft.model,
                    style: GoogleFonts.rajdhani(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white)),
              ),
              _buildStatusChip(aircraft.status),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow('Matrícula', aircraft.registration),
          _infoRow('Aerolínea ID', aircraft.airlineId),
          const SizedBox(height: 6),
          Text('Asientos: ${aircraft.totalSeats} total'
              '  |  ${aircraft.firstClassSeats} primera'
              '  |  ${aircraft.businessSeats} business'
              '  |  ${aircraft.economySeats} económica',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.gray, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 32,
                child: TextButton.icon(
                  onPressed: () => _openForm(aircraft: aircraft),
                  icon: const Icon(Icons.edit, size: 16, color: AppColors.cyan),
                  label: Text('EDITAR',
                      style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cyan)),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: TextButton.icon(
                  onPressed: () => _confirmDelete(aircraft),
                  icon: const Icon(Icons.delete, size: 16, color: AppColors.chipRed),
                  label: Text('ELIMINAR',
                      style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.chipRed)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray)),
          Text(value,
              style: const TextStyle(fontSize: 12, color: AppColors.white)),
        ],
      ),
    );
  }
}
