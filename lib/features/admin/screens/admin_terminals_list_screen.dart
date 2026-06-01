import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/terminal_model.dart';
import '../../../shared/models/result_state.dart';
import '../../../core/theme/app_theme.dart';
import 'admin_terminal_form_dialog.dart';

class AdminTerminalsListScreen extends StatefulWidget {
  const AdminTerminalsListScreen({super.key});

  @override
  State<AdminTerminalsListScreen> createState() =>
      _AdminTerminalsListScreenState();
}

class _AdminTerminalsListScreenState extends State<AdminTerminalsListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminProvider>().fetchAllTerminals();
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
        title: const Text('TERMINALES'),
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
                hintText: 'Buscar por nombre o código...',
                prefixIcon: Icon(Icons.search, color: AppColors.gray, size: 20),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (ctx, provider, _) {
                final state = provider.terminalsState;
                if (state is Loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is Error<List<TerminalModel>>) {
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
                final terminals = state is Success<List<TerminalModel>>
                    ? state.data
                    : <TerminalModel>[];
                final filtered = terminals
                    .where(
                      (t) =>
                          t.name.toLowerCase().contains(_query) ||
                          t.code.toLowerCase().contains(_query),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay terminales registradas',
                      style: TextStyle(color: AppColors.gray),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => provider.fetchAllTerminals(),
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

  void _createOrEdit({TerminalModel? terminal}) async {
    final provider = context.read<AdminProvider>();
    final result = await showTerminalFormDialog(context, terminal: terminal);
    if (result == null || !mounted) return;
    if (terminal != null) {
      await provider.updateTerminal(result);
    } else {
      await provider.createTerminal(result);
    }
  }

  Widget _buildCard(TerminalModel terminal, AdminProvider provider) {
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        terminal.name,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${terminal.gatesCount} puertas',
                        style: const TextStyle(
                          color: AppColors.gray,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    terminal.code,
                    style: const TextStyle(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.cyan, size: 20),
            onPressed: () => _createOrEdit(terminal: terminal),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.chipRed, size: 20),
            onPressed: () => _confirmDelete(terminal, provider),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(TerminalModel terminal, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Eliminar Terminal',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Eliminar terminal "${terminal.name}"?',
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
              await provider.deleteTerminal(terminal.id);
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
}
