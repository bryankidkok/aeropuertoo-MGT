import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/result_state.dart';
import '../../../shared/models/airline_model.dart';
import 'admin_airline_form_dialog.dart';

class AdminAirlinesListScreen extends StatefulWidget {
  const AdminAirlinesListScreen({super.key});

  @override
  State<AdminAirlinesListScreen> createState() =>
      _AdminAirlinesListScreenState();
}

class _AdminAirlinesListScreenState extends State<AdminAirlinesListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllAirlines();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AirlineModel> _filter(List<AirlineModel> airlines) {
    if (_searchQuery.isEmpty) return airlines;
    final query = _searchQuery.toLowerCase();
    return airlines
        .where(
          (a) =>
              a.name.toLowerCase().contains(query) ||
              a.iataCode.toLowerCase().contains(query) ||
              a.country.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _confirmDelete(AirlineModel airline) async {
    final provider = context.read<AdminProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Eliminar Aerolínea',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Eliminar "${airline.name}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.gray),
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
      await provider.deleteAirline(airline.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('AEROLÍNEAS'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.cyan.withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.cyan,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => showAirlineFormDialog(context),
            icon: const Icon(Icons.add, color: AppColors.cyan, size: 20),
            label: const Text(
              'AGREGAR',
              style: TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (_, provider, _) {
          final state = provider.airlinesState;
          if (state is Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is Error<List<AirlineModel>>) {
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
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => provider.fetchAllAirlines(),
                    icon: const Icon(Icons.refresh, color: AppColors.cyan),
                    label: const Text(
                      'REINTENTAR',
                      style: TextStyle(color: AppColors.cyan),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is! Success<List<AirlineModel>>) {
            return const SizedBox.shrink();
          }

          final airlines = _filter(state.data);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, código IATA o país...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.gray),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.gray,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              if (airlines.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No se encontraron aerolíneas',
                      style: TextStyle(color: AppColors.gray),
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.fetchAllAirlines(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: airlines.length,
                      itemBuilder: (_, i) =>
                          _buildAirlineCard(airlines[i], provider),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAirlineCard(AirlineModel airline, AdminProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          airline.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          airline.iataCode,
                          style: const TextStyle(
                            color: AppColors.cyan,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (airline.country.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.public,
                            size: 14,
                            color: AppColors.gray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            airline.country,
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
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: airline.isActive
                          ? AppColors.chipGreen.withValues(alpha: 0.15)
                          : AppColors.chipRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      airline.isActive ? 'ACTIVA' : 'INACTIVA',
                      style: TextStyle(
                        color: airline.isActive
                            ? AppColors.chipGreen
                            : AppColors.chipRed,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.cyan, size: 20),
              onPressed: () => showAirlineFormDialog(context, airline: airline),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: AppColors.chipRed,
                size: 20,
              ),
              onPressed: () => _confirmDelete(airline),
            ),
          ],
        ),
      ),
    );
  }
}
