import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/result_state.dart';
import '../models/gate_model.dart';
import '../models/flight_model.dart';
import '../models/incident_model.dart';

class OperationsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ResultState<List<GateModel>> _gatesState = const Idle();
  ResultState<List<FlightModel>> _todayFlightsState = const Idle();

  ResultState<List<GateModel>> get gatesState => _gatesState;
  ResultState<List<FlightModel>> get todayFlightsState => _todayFlightsState;

  List<GateModel> get gates =>
      _gatesState is Success<List<GateModel>> ? (_gatesState as Success<List<GateModel>>).data : [];
  List<FlightModel> get todayFlights =>
      _todayFlightsState is Success<List<FlightModel>>
          ? (_todayFlightsState as Success<List<FlightModel>>).data
          : [];

  bool get isLoadingGates => _gatesState is Loading;
  bool get isLoadingFlights => _todayFlightsState is Loading;

  Future<void> fetchGates() async {
    _gatesState = const Loading();
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('gates')
          .orderBy('name')
          .get();
      final list = snapshot.docs.map((doc) {
        return GateModel.fromMap(doc.id, doc.data());
      }).toList();
      _gatesState = Success(list);
    } catch (e) {
      _gatesState = const Error('Error al cargar puertas de embarque');
    }
    notifyListeners();
  }

  Future<bool> assignGateToFlight(String gateId, String flightId) async {
    try {
      final flightDoc = await _firestore.collection('flights').doc(flightId).get();
      final flightNumber = flightDoc.data()?['flightNumber'] as String? ?? '';

      await _firestore.collection('gates').doc(gateId).update({
        'status': GateStatus.occupied.value,
        'currentFlightId': flightId,
        'currentFlightNumber': flightNumber,
      });

      await _firestore.collection('flights').doc(flightId).update({
        'gateId': gateId,
      });

      await fetchGates();
      return true;
    } catch (e) {
      _gatesState = const Error('Error al asignar puerta');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGateStatus(String gateId, GateStatus status) async {
    try {
      final update = <String, dynamic>{'status': status.value};
      if (status == GateStatus.available) {
        update['currentFlightId'] = null;
        update['currentFlightNumber'] = null;
      }
      await _firestore.collection('gates').doc(gateId).update(update);
      await fetchGates();
      return true;
    } catch (e) {
      _gatesState = const Error('Error al actualizar estado de puerta');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTodayFlights() async {
    _todayFlightsState = const Loading();
    notifyListeners();

    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('flights')
          .where('departureTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('departureTime', isLessThan: Timestamp.fromDate(end))
          .orderBy('departureTime')
          .get();

      final list = snapshot.docs.map((doc) {
        return FlightModel.fromMap(doc.id, doc.data());
      }).toList();
      _todayFlightsState = Success(list);
    } catch (e) {
      _todayFlightsState = const Error('Error al cargar vuelos del día');
    }
    notifyListeners();
  }

  ResultState<List<IncidentModel>> _incidentsState = const Idle();

  ResultState<List<IncidentModel>> get incidentsState => _incidentsState;
  List<IncidentModel> get incidents =>
      _incidentsState is Success<List<IncidentModel>> ? (_incidentsState as Success<List<IncidentModel>>).data : [];

  Future<void> fetchIncidents() async {
    _incidentsState = const Loading();
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('incidents')
          .orderBy('createdAt', descending: true)
          .get();
      final list = snapshot.docs
          .map((doc) => IncidentModel.fromMap(doc.id, doc.data()))
          .toList();
      _incidentsState = Success(list);
    } catch (e) {
      _incidentsState = const Error('Error al cargar incidencias');
    }
    notifyListeners();
  }

  Future<bool> createIncident({
    required String flightId,
    required String flightNumber,
    required IncidentType type,
    required IncidentSeverity severity,
    required String description,
    required String actionsTaken,
    required String reportedById,
    required String reportedByName,
  }) async {
    try {
      await _firestore.collection('incidents').add({
        'flightId': flightId,
        'flightNumber': flightNumber,
        'type': type.value,
        'severity': severity.value,
        'description': description,
        'actionsTaken': actionsTaken,
        'reportedById': reportedById,
        'reportedByName': reportedByName,
        'status': IncidentStatus.open.value,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'resolvedAt': null,
      });
      await fetchIncidents();
      return true;
    } catch (e) {
      _incidentsState = const Error('Error al crear incidencia');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateIncidentStatus(String incidentId, IncidentStatus status) async {
    try {
      final update = <String, dynamic>{'status': status.value};
      if (status == IncidentStatus.resolved) {
        update['resolvedAt'] = Timestamp.fromDate(DateTime.now());
      }
      await _firestore.collection('incidents').doc(incidentId).update(update);
      await fetchIncidents();
      return true;
    } catch (e) {
      return false;
    }
  }
}
