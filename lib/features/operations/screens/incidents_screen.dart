import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/incident_model.dart';

import '../../../shared/providers/flight_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<IncidentModel> _incidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlightProvider>().fetchFlights();
    });
    _fetchIncidents();
  }

  Future<void> _fetchIncidents() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore
          .collection('incidents')
          .orderBy('createdAt', descending: true)
          .get();
      final list = snapshot.docs.map((doc) {
        return IncidentModel.fromMap(doc.id, doc.data());
      }).toList();
      setState(() {
        _incidents = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _severityColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.low:
        return AppColors.chipGreen;
      case IncidentSeverity.medium:
        return AppColors.chipYellow;
      case IncidentSeverity.high:
        return AppColors.orange;
      case IncidentSeverity.critical:
        return AppColors.chipRed;
    }
  }

  String _typeLabel(IncidentType type) {
    switch (type) {
      case IncidentType.delay:
        return 'DEMORA';
      case IncidentType.cancellation:
        return 'CANCELACIÓN';
      case IncidentType.emergency:
        return 'EMERGENCIA';
      case IncidentType.technical:
        return 'TÉCNICO';
      case IncidentType.other:
        return 'OTRO';
    }
  }

  String _statusLabel(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.open:
        return 'ABIERTO';
      case IncidentStatus.inProgress:
        return 'EN CURSO';
      case IncidentStatus.resolved:
        return 'RESUELTO';
    }
  }

  Color _statusColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.open:
        return AppColors.chipRed;
      case IncidentStatus.inProgress:
        return AppColors.chipYellow;
      case IncidentStatus.resolved:
        return AppColors.chipGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INCIDENCIAS'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewIncidentDialog(),
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('NUEVA INCIDENCIA'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _incidents.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber, color: AppColors.gray, size: 48),
                            SizedBox(height: 16),
                            Text(
                              'No hay incidencias registradas',
                              style: TextStyle(color: AppColors.gray),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchIncidents,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          itemCount: _incidents.length,
                          itemBuilder: (context, index) {
                            final incident = _incidents[index];
                            return _buildIncidentCard(incident);
                          },
                        ),
                      ),
          ),
          const AppBottomNav(currentIndex: 2),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(IncidentModel incident) {
    final sevColor = _severityColor(incident.severity);
    final timeFormat = DateFormat('dd/MM HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: sevColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                incident.flightNumber,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: sevColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _typeLabel(incident.type),
                  style: TextStyle(
                    color: sevColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            incident.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.gray, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeFormat.format(incident.createdAt),
                style: const TextStyle(color: AppColors.gray, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(incident.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusColor(incident.status).withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  _statusLabel(incident.status),
                  style: TextStyle(
                    color: _statusColor(incident.status),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNewIncidentDialog() {
    final flights = context.read<FlightProvider>().flights;
    final user = context.read<AuthProvider>().user;

    String? selectedFlightId;
    String selectedFlightNumber = '';
    IncidentType selectedType = IncidentType.delay;
    IncidentSeverity selectedSeverity = IncidentSeverity.medium;
    final descriptionController = TextEditingController();
    final actionsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'NUEVA INCIDENCIA',
            style: TextStyle(color: AppColors.white, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedFlightId,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      labelText: 'Vuelo',
                      hintText: 'Seleccionar vuelo',
                    ),
                    items: flights.map((f) {
                      return DropdownMenuItem(
                        value: f.id,
                        child: Text(
                          '${f.flightNumber} - ${f.originCode}→${f.destinationCode}',
                          style: const TextStyle(color: AppColors.white, fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      selectedFlightId = val;
                      selectedFlightNumber = flights.firstWhere((f) => f.id == val).flightNumber;
                    },
                    validator: (v) => v == null ? 'Selecciona un vuelo' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<IncidentType>(
                    initialValue: selectedType,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                    ),
                    items: IncidentType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(
                          _typeLabel(t),
                          style: const TextStyle(color: AppColors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) selectedType = val;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<IncidentSeverity>(
                    initialValue: selectedSeverity,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      labelText: 'Severidad',
                    ),
                    items: IncidentSeverity.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _severityColor(s),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              s.name.toUpperCase(),
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) selectedSeverity = val;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Describe la incidencia...',
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Ingresa una descripción' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: actionsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Acciones tomadas',
                      hintText: 'Acciones realizadas...',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCELAR', style: TextStyle(color: AppColors.gray)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (user == null) return;

                try {
                  await _firestore.collection('incidents').add({
                    'flightId': selectedFlightId!,
                    'flightNumber': selectedFlightNumber,
                    'type': selectedType.value,
                    'severity': selectedSeverity.value,
                    'description': descriptionController.text.trim(),
                    'actionsTaken': actionsController.text.trim(),
                    'reportedById': user.uid,
                    'reportedByName': user.displayName,
                    'status': IncidentStatus.open.value,
                    'createdAt': Timestamp.fromDate(DateTime.now()),
                    'resolvedAt': null,
                  });
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  await _fetchIncidents();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al crear incidencia')),
                  );
                }
              },
              child: const Text('GUARDAR'),
            ),
          ],
        );
      },
    );
  }
}
