import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/gate_model.dart';
import '../../../shared/models/result_state.dart';
import '../../../core/theme/app_theme.dart';
import 'admin_gate_form_dialog.dart';

class AdminGatesListScreen extends StatefulWidget {
  const AdminGatesListScreen({super.key});

  @override
  State<AdminGatesListScreen> createState() => _AdminGatesListScreenState();
}

class _AdminGatesListScreenState extends State<AdminGatesListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminProvider>().fetchAllGates();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PUERTAS'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add, color: AppColors.cyan, size: 18),
            label: const Text(
              'AGREGAR',
              style: TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            onPressed: () => _createOrEdit(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o terminal...',
                prefixIcon: Icon(Icons.search, color: AppColors.gray, size: 20),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (ctx, provider, _) {
                final state = provider.gatesState;
                if (state is Loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is Error<List<GateModel>>) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.chipRed,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (state).message,
                          style: const TextStyle(color: AppColors.gray),
                        ),
                      ],
                    ),
                  );
                }
                final gates = state is Success<List<GateModel>>
                    ? state.data
                    : <GateModel>[];
                final filtered = gates
                    .where(
                      (g) =>
                          g.name.toLowerCase().contains(_query) ||
                          g.terminalName.toLowerCase().contains(_query),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay puertas registradas',
                      style: TextStyle(color: AppColors.gray),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => provider.fetchAllGates(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _buildCard(filtered[i], provider),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _createOrEdit({GateModel? gate}) async {
    final provider = context.read<AdminProvider>();
    final result = await showGateFormDialog(context, gate: gate);
    if (result == null || !mounted) return;
    if (gate != null) {
      await provider.updateGate(result);
    } else {
      await provider.createGate(result);
    }
  }

  Widget _buildCard(GateModel gate, AdminProvider provider) {
    final statusColor = _statusColor(gate.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                  gate.name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gate.terminalName,
                  style: const TextStyle(color: AppColors.gray, fontSize: 13),
                ),
                if (gate.currentFlightNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Vuelo: ${gate.currentFlightNumber}',
                    style: const TextStyle(color: AppColors.cyan, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              _statusLabel(gate.status),
              style: TextStyle(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.cyan, size: 20),
            onPressed: () => _createOrEdit(gate: gate),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.chipRed, size: 20),
            onPressed: () => _confirmDelete(gate, provider),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(GateModel gate, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Eliminar Puerta',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Eliminar puerta "${gate.name}"?',
          style: const TextStyle(color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: AppColors.gray),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteGate(gate.id);
            },
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: AppColors.chipRed),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(GateStatus s) => switch (s) {
    GateStatus.available => AppColors.chipGreen,
    GateStatus.occupied => AppColors.chipYellow,
    GateStatus.maintenance => AppColors.chipRed,
  };

  String _statusLabel(GateStatus s) => switch (s) {
    GateStatus.available => 'Disponible',
    GateStatus.occupied => 'Ocupada',
    GateStatus.maintenance => 'Mantenimiento',
  };
}
