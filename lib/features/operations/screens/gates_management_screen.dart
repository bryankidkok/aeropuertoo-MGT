import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/operations_provider.dart';
import '../../../shared/models/gate_model.dart';
import '../../../shared/models/flight_model.dart';
import '../../../shared/models/result_state.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class GatesManagementScreen extends StatefulWidget {
  const GatesManagementScreen({super.key});

  @override
  State<GatesManagementScreen> createState() => _GatesManagementScreenState();
}

class _GatesManagementScreenState extends State<GatesManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperationsProvider>().fetchGates();
    });
  }

  Color _gateColor(GateStatus status) {
    switch (status) {
      case GateStatus.available:
        return AppColors.cyan;
      case GateStatus.occupied:
        return AppColors.orange;
      case GateStatus.maintenance:
        return AppColors.gray;
    }
  }

  String _gateStatusLabel(GateStatus status) {
    switch (status) {
      case GateStatus.available:
        return 'DISPONIBLE';
      case GateStatus.occupied:
        return 'OCUPADA';
      case GateStatus.maintenance:
        return 'MANTENIMIENTO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PUERTAS DE EMBARQUE'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<OperationsProvider>(
              builder: (context, provider, _) {
                final state = provider.gatesState;

                if (state is Loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is Error<List<GateModel>>) {
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
                            onPressed: () => provider.fetchGates(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('REINTENTAR'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final gates = provider.gates;

                if (gates.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.meeting_room, color: AppColors.gray, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'No hay puertas registradas',
                          style: TextStyle(color: AppColors.gray),
                        ),
                      ],
                    ),
                  );
                }

                final grouped = <String, List<GateModel>>{};
                for (final gate in gates) {
                  grouped.putIfAbsent(gate.terminalName, () => []).add(gate);
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchGates(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final terminal = grouped.keys.elementAt(index);
                      final terminalGates = grouped[terminal]!;
                      return _buildTerminalSection(terminal, terminalGates, provider);
                    },
                  ),
                );
              },
            ),
          ),
          const AppBottomNav(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildTerminalSection(String terminalName, List<GateModel> gates, OperationsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            terminalName.toUpperCase(),
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gates.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final gate = gates[index];
            return _buildGateCard(gate);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGateCard(GateModel gate) {
    final color = _gateColor(gate.status);
    final label = _gateStatusLabel(gate.status);

    return GestureDetector(
      onTap: () => _showGateBottomSheet(gate),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gate.name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGateBottomSheet(GateModel gate) {
    final provider = context.read<OperationsProvider>();
    GateStatus selectedStatus = gate.status;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    gate.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _gateStatusLabel(gate.status),
                    style: TextStyle(
                      color: _gateColor(gate.status),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (gate.status == GateStatus.occupied && gate.currentFlightNumber != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flight, color: AppColors.orange, size: 16),
                          const SizedBox(width: 10),
                          Text(
                            'Vuelo: ${gate.currentFlightNumber}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'CAMBIAR ESTADO',
                    style: TextStyle(
                      color: AppColors.gray,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<GateStatus>(
                    initialValue: selectedStatus,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      hintText: 'Seleccionar estado',
                    ),
                    items: GateStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          _gateStatusLabel(s),
                          style: const TextStyle(color: AppColors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => selectedStatus = val);
                        provider.updateGateStatus(gate.id, val);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: gate.status == GateStatus.occupied
                              ? () async {
                                  await provider.updateGateStatus(gate.id, GateStatus.available);
                                  if (!ctx.mounted) return;
                                  Navigator.of(ctx).pop();
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.chipGreen,
                            side: const BorderSide(color: AppColors.chipGreen),
                          ),
                          child: const Text('LIBERAR PUERTA'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: gate.status != GateStatus.occupied
                              ? () {
                                  Navigator.of(ctx).pop();
                                  _showAssignFlightDialog(gate);
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.cyan,
                            side: const BorderSide(color: AppColors.cyan),
                          ),
                          child: const Text('ASIGNAR VUELO'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAssignFlightDialog(GateModel gate) {
    final provider = context.read<OperationsProvider>();
    String? selectedFlightId;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'ASIGNAR VUELO',
            style: TextStyle(color: AppColors.white, fontSize: 18),
          ),
          content: FutureBuilder<List<FlightModel>>(
            future: provider.fetchTodayFlights().then((_) => provider.todayFlights.where((f) => f.gateId.isEmpty).toList()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final availableFlights = snapshot.data ?? <FlightModel>[];

              if (availableFlights.isEmpty) {
                return const Text(
                  'No hay vuelos sin puerta asignada',
                  style: TextStyle(color: AppColors.gray),
                );
              }

              return StatefulBuilder(
                builder: (context, setDialogState) {
                  return DropdownButtonFormField<String>(
                    initialValue: selectedFlightId,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      hintText: 'Seleccionar vuelo',
                    ),
                    items: availableFlights.map((f) {
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text(
                          '${f.flightNumber} - ${f.originCode}→${f.destinationCode}',
                          style: const TextStyle(color: AppColors.white, fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() => selectedFlightId = val);
                    },
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCELAR', style: TextStyle(color: AppColors.gray)),
            ),
            ElevatedButton(
              onPressed: selectedFlightId == null
                  ? null
                  : () async {
                      await provider.assignGateToFlight(gate.id, selectedFlightId!);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
              child: const Text('ASIGNAR'),
            ),
          ],
        );
      },
    );
  }
}
