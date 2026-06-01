import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/flight_model.dart';
import '../../../shared/models/result_state.dart';
import '../../../shared/widgets/status_chip.dart';
import 'admin_flight_form_dialog.dart';

class AdminFlightsListScreen extends StatefulWidget {
  const AdminFlightsListScreen({super.key});

  @override
  State<AdminFlightsListScreen> createState() => _AdminFlightsListScreenState();
}

class _AdminFlightsListScreenState extends State<AdminFlightsListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AdminProvider>().fetchAllFlights();
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
        title: Text('VUELOS', style: GoogleFonts.rajdhani(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white)),
        actions: [
          TextButton.icon(
            onPressed: () => showFlightFormDialog(context),
            icon: const Icon(Icons.add, color: AppColors.cyan, size: 18),
            label: const Text('AGREGAR', style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 13)),
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
              decoration: InputDecoration(
                hintText: 'Buscar por número, origen o destino...',
                prefixIcon: const Icon(Icons.search, color: AppColors.gray, size: 20),
                filled: true,
                fillColor: AppColors.inputFill,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, _) {
                final state = provider.flightsState;

                if (state is Loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is Error<List<FlightModel>>) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.chipRed, size: 48),
                        const SizedBox(height: 12),
                        Text((state).message, style: const TextStyle(color: AppColors.gray)),
                      ],
                    ),
                  );
                }

                final flights = state is Success<List<FlightModel>> ? state.data : <FlightModel>[];
                final filtered = flights.where((f) =>
                  f.flightNumber.toLowerCase().contains(_query) ||
                  f.originName.toLowerCase().contains(_query) ||
                  f.destinationName.toLowerCase().contains(_query) ||
                  f.originCode.toLowerCase().contains(_query) ||
                  f.destinationCode.toLowerCase().contains(_query)
                ).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flight_takeoff, color: AppColors.gray.withValues(alpha: 0.4), size: 64),
                        const SizedBox(height: 16),
                        const Text('No hay vuelos registrados', style: TextStyle(color: AppColors.gray, fontSize: 16)),
                      ],
                    ),
                  );
                }

                final dateFmt = DateFormat('dd/MM/yyyy');
                final timeFmt = DateFormat('HH:mm');

                return RefreshIndicator(
                  onRefresh: () => provider.fetchAllFlights(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final f = filtered[i];
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
                                  Row(
                                    children: [
                                      Text(f.flightNumber,
                                        style: GoogleFonts.rajdhani(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      StatusChip(
                                        label: StatusChip.labelForStatus(f.status.name),
                                        color: StatusChip.colorForStatus(f.status.name),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${f.originCode} → ${f.destinationCode}',
                                    style: const TextStyle(color: AppColors.gray, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${dateFmt.format(f.departureTime)} ${timeFmt.format(f.departureTime)}',
                                    style: const TextStyle(color: AppColors.gray, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(f.airlineName,
                                    style: const TextStyle(color: AppColors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => showFlightFormDialog(context, flight: f),
                              icon: const Icon(Icons.edit, color: AppColors.cyan, size: 20),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              onPressed: () => _confirmDelete(context, f, provider),
                              icon: const Icon(Icons.delete, color: AppColors.chipRed, size: 20),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, FlightModel flight, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text('Eliminar Vuelo',
          style: GoogleFonts.rajdhani(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        content: Text(
          '¿Estás seguro de eliminar el vuelo ${flight.flightNumber}?\nEsta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR', style: TextStyle(color: AppColors.gray)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await provider.deleteFlight(flight.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Vuelo eliminado' : 'Error al eliminar vuelo'),
                  backgroundColor: ok ? AppColors.chipGreen : AppColors.chipRed,
                ),
              );
            },
            child: const Text('ELIMINAR', style: TextStyle(color: AppColors.chipRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
