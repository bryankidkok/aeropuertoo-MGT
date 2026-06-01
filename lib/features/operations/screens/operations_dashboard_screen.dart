import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/operations_provider.dart';
import '../../../shared/models/result_state.dart';
import '../../../shared/models/flight_model.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class OperationsDashboardScreen extends StatefulWidget {
  const OperationsDashboardScreen({super.key});

  @override
  State<OperationsDashboardScreen> createState() => _OperationsDashboardScreenState();
}

class _OperationsDashboardScreenState extends State<OperationsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperationsProvider>().fetchTodayFlights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CENTRO DE OPERACIONES'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: AppColors.orange),
              tooltip: 'IR AL PANEL ADMIN',
              onPressed: () => context.go('/admin'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderCard(user?.displayName ?? 'Empleado'),
          Expanded(
            child: Consumer<OperationsProvider>(
              builder: (context, provider, _) {
                final state = provider.todayFlightsState;

                if (state is Loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is Error<List<FlightModel>>) {
                  final err = state;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off, color: AppColors.gray, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            err.message,
                            style: const TextStyle(color: AppColors.gray),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => provider.fetchTodayFlights(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('REINTENTAR'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final flights = provider.todayFlights;

                if (flights.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flight_takeoff, color: AppColors.gray, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'No hay vuelos programados para hoy',
                          style: TextStyle(color: AppColors.gray),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchTodayFlights(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: flights.length,
                    itemBuilder: (context, index) {
                      final flight = flights[index];
                      return _buildFlightCard(flight);
                    },
                  ),
                );
              },
            ),
          ),
          const AppBottomNav(currentIndex: 0),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(String name) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyan.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'E',
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Terminal 1',
                  style: TextStyle(color: AppColors.gray, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.chipGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.chipGreen.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.chipGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'TURNO ACTIVO',
                  style: TextStyle(
                    color: AppColors.chipGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightCard(FlightModel flight) {
    final timeFormat = DateFormat('HH:mm');
    final statusColor = StatusChip.colorForStatus(flight.status.value);
    final statusLabel = StatusChip.labelForStatus(flight.status.value);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                flight.flightNumber,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              StatusChip(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.flight, color: AppColors.cyan, size: 14),
              const SizedBox(width: 6),
              Text(
                '${flight.originCode} → ${flight.destinationCode}',
                style: const TextStyle(color: AppColors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.gray, size: 14),
              const SizedBox(width: 6),
              Text(
                timeFormat.format(flight.departureTime),
                style: const TextStyle(color: AppColors.gray, fontSize: 13),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.meeting_room, color: AppColors.gray, size: 14),
              const SizedBox(width: 6),
              Text(
                flight.gateName.isNotEmpty ? flight.gateName : 'Sin asignar',
                style: const TextStyle(color: AppColors.gray, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.people, color: AppColors.gray, size: 14),
              const SizedBox(width: 6),
              Text(
                'Check-in: ${flight.totalSeats - flight.availableSeats} / ${flight.totalSeats}',
                style: const TextStyle(color: AppColors.gray, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
