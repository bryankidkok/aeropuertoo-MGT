import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/maintenance_log_model.dart';
import '../../../shared/models/result_state.dart';
import 'admin_maintenance_form_dialog.dart';

Color _statusColor(MaintenanceStatus s) {
  switch (s) {
    case MaintenanceStatus.scheduled:
      return AppColors.chipYellow;
    case MaintenanceStatus.inProgress:
      return AppColors.cyan;
    case MaintenanceStatus.completed:
      return AppColors.chipGreen;
    case MaintenanceStatus.deferred:
      return AppColors.chipRed;
  }
}

String _statusLabel(MaintenanceStatus s) {
  switch (s) {
    case MaintenanceStatus.scheduled:
      return 'Programado';
    case MaintenanceStatus.inProgress:
      return 'En Progreso';
    case MaintenanceStatus.completed:
      return 'Completado';
    case MaintenanceStatus.deferred:
      return 'Diferido';
  }
}

String _typeLabel(MaintenanceType t) {
  switch (t) {
    case MaintenanceType.routine:
      return 'Rutina';
    case MaintenanceType.repair:
      return 'Reparaci\u00F3n';
    case MaintenanceType.inspection:
      return 'Inspecci\u00F3n';
    case MaintenanceType.emergency:
      return 'Emergencia';
  }
}

class AdminMaintenanceListScreen extends StatefulWidget {
  const AdminMaintenanceListScreen({super.key});

  @override
  State<AdminMaintenanceListScreen> createState() =>
      _AdminMaintenanceListScreenState();
}

class _AdminMaintenanceListScreenState
    extends State<AdminMaintenanceListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final provider = context.read<AdminProvider>();
    provider.fetchAllMaintenanceLogs();
    provider.fetchAllAircrafts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MaintenanceLogModel> _filter(List<MaintenanceLogModel> logs) {
    if (_searchQuery.isEmpty) return logs;
    final q = _searchQuery.toLowerCase();
    return logs.where((l) {
      return l.aircraftRegistration.toLowerCase().contains(q) ||
          l.type.name.toLowerCase().contains(q) ||
          l.description.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _deleteLog(String id) async {
    final provider = context.read<AdminProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Confirmar Eliminaci\u00F3n',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '\u00BFEliminar este registro de mantenimiento?',
          style: TextStyle(color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: AppColors.gray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: AppColors.chipRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await provider.deleteMaintenanceLog(id);
    }
  }

  Future<void> _createOrEdit({MaintenanceLogModel? log}) async {
    final provider = context.read<AdminProvider>();
    final result = await showMaintenanceFormDialog(context, log: log);
    if (result == null || !mounted) return;
    if (log != null) {
      await provider.updateMaintenanceLog(result);
    } else {
      await provider.createMaintenanceLog(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MANTENIMIENTO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.cyan),
            tooltip: 'Agregar',
            onPressed: () => _createOrEdit(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (ctx, provider, _) {
                final state = provider.maintenanceState;
                if (state is Loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is Error<List<MaintenanceLogModel>>) {
                  return Center(
                    child: Text(
                      (state).message,
                      style: const TextStyle(color: AppColors.chipRed),
                    ),
                  );
                }
                if (state is Idle) {
                  return const SizedBox.shrink();
                }
                if (state is Success<List<MaintenanceLogModel>>) {
                  final filtered = _filter(state.data);
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Sin registros de mantenimiento',
                        style: TextStyle(color: AppColors.gray),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _buildCard(filtered[i]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Buscar por matr\u00EDcula, tipo o descripci\u00F3n...',
          prefixIcon: const Icon(Icons.search, color: AppColors.gray),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.gray),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildCard(MaintenanceLogModel log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  log.aircraftRegistration,
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              _buildChip(_typeLabel(log.type), AppColors.gray),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChip(_statusLabel(log.status), _statusColor(log.status)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.cyan, size: 20),
                onPressed: () => _createOrEdit(log: log),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: AppColors.chipRed,
                  size: 20,
                ),
                onPressed: () => _deleteLog(log.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.gray, size: 14),
              const SizedBox(width: 6),
              Text(
                '${_dateFormat.format(log.startDate)}${log.endDate != null ? ' - ${_dateFormat.format(log.endDate!)}' : ''}',
                style: const TextStyle(fontSize: 12, color: AppColors.gray),
              ),
            ],
          ),
          if (log.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              log.description,
              style: const TextStyle(fontSize: 13, color: AppColors.gray),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
