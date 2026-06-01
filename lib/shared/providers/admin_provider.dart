import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:uuid/uuid.dart';

import '../models/result_state.dart';
import '../models/flight_model.dart';
import '../models/airline_model.dart';
import '../models/aircraft_model.dart';
import '../models/gate_model.dart';
import '../models/terminal_model.dart';
import '../models/employee_model.dart';
import '../models/passenger_model.dart';
import '../models/maintenance_log_model.dart';
import '../models/user_model.dart';

abstract class _Collections {
  static const flights = 'flights';
  static const airlines = 'airlines';
  static const aircrafts = 'aircrafts';
  static const gates = 'gates';
  static const terminals = 'terminals';
  static const employees = 'employees';
  static const passengers = 'passengers';
  static const users = 'users';
  static const bookings = 'bookings';
  static const maintenance = 'maintenance_logs';
}

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  ResultState<List<FlightModel>> _flightsState = const Idle();
  ResultState<List<AirlineModel>> _airlinesState = const Idle();
  ResultState<List<AircraftModel>> _aircraftsState = const Idle();
  ResultState<List<GateModel>> _gatesState = const Idle();
  ResultState<List<TerminalModel>> _terminalsState = const Idle();
  ResultState<List<EmployeeModel>> _employeesState = const Idle();
  ResultState<List<PassengerModel>> _passengersState = const Idle();
  ResultState<List<MaintenanceLogModel>> _maintenanceState = const Idle();
  ResultState<List<UserModel>> _usersState = const Idle();

  // Getters
  ResultState<List<FlightModel>> get flightsState => _flightsState;
  ResultState<List<AirlineModel>> get airlinesState => _airlinesState;
  ResultState<List<AircraftModel>> get aircraftsState => _aircraftsState;
  ResultState<List<GateModel>> get gatesState => _gatesState;
  ResultState<List<TerminalModel>> get terminalsState => _terminalsState;
  ResultState<List<EmployeeModel>> get employeesState => _employeesState;
  ResultState<List<PassengerModel>> get passengersState => _passengersState;
  ResultState<List<MaintenanceLogModel>> get maintenanceState =>
      _maintenanceState;
  ResultState<List<UserModel>> get usersState => _usersState;

  bool get isLoading =>
      _flightsState is Loading ||
      _airlinesState is Loading ||
      _aircraftsState is Loading;

  // ──────────────────────────────────────────────
  // FLIGHTS CRUD
  // ──────────────────────────────────────────────

  Future<void> fetchAllFlights() async {
    _flightsState = const Loading();
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(_Collections.flights)
          .orderBy('departureTime', descending: true)
          .get();
      _flightsState = Success(
        snapshot.docs
            .map((doc) => FlightModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      _flightsState = const Error('Error al cargar vuelos');
    }
    notifyListeners();
  }

  Future<bool> createFlight(FlightModel flight) async {
    try {
      final ref = _firestore.collection(_Collections.flights).doc(_uuid.v4());
      final data = flight.copyWith(id: ref.id).toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(data);
      await fetchAllFlights();
      return true;
    } catch (e) {
      _flightsState = const Error('Error al crear vuelo');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFlight(FlightModel flight) async {
    try {
      await _firestore
          .collection(_Collections.flights)
          .doc(flight.id)
          .update(flight.toMap());
      await fetchAllFlights();
      return true;
    } catch (e) {
      _flightsState = const Error('Error al actualizar vuelo');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFlight(String id) async {
    try {
      await _firestore.collection(_Collections.flights).doc(id).delete();
      await fetchAllFlights();
      return true;
    } catch (e) {
      _flightsState = const Error('Error al eliminar vuelo');
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // AIRLINES CRUD
  // ──────────────────────────────────────────────

  Future<void> fetchAllAirlines() async {
    _airlinesState = const Loading();
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(_Collections.airlines)
          .orderBy('name')
          .get();
      _airlinesState = Success(
        snapshot.docs
            .map((doc) => AirlineModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      _airlinesState = const Error('Error al cargar aerolíneas');
    }
    notifyListeners();
  }

  Future<bool> createAirline(AirlineModel airline) async {
    try {
      final ref = _firestore.collection(_Collections.airlines).doc(_uuid.v4());
      await ref.set(airline.copyWith(id: ref.id).toMap());
      await fetchAllAirlines();
      return true;
    } catch (e) {
      _airlinesState = const Error('Error al crear aerolínea');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAirline(AirlineModel airline) async {
    try {
      await _firestore
          .collection(_Collections.airlines)
          .doc(airline.id)
          .update(airline.toMap());
      await fetchAllAirlines();
      return true;
    } catch (e) {
      _airlinesState = const Error('Error al actualizar aerolínea');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAirline(String id) async {
    try {
      await _firestore.collection(_Collections.airlines).doc(id).delete();
      await fetchAllAirlines();
      return true;
    } catch (e) {
      _airlinesState = const Error('Error al eliminar aerolínea');
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // AIRCRAFTS CRUD
  // ──────────────────────────────────────────────

  Future<void> fetchAllAircrafts() async {
    _aircraftsState = const Loading();
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(_Collections.aircrafts)
          .orderBy('registration')
          .get();
      _aircraftsState = Success(
        snapshot.docs
            .map((doc) => AircraftModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      _aircraftsState = const Error('Error al cargar aeronaves');
    }
    notifyListeners();
  }

  Future<bool> createAircraft(AircraftModel aircraft) async {
    try {
      final ref = _firestore.collection(_Collections.aircrafts).doc(_uuid.v4());
      await ref.set(aircraft.copyWith(id: ref.id).toMap());
      await fetchAllAircrafts();
      return true;
    } catch (e) {
      _aircraftsState = const Error('Error al crear aeronave');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAircraft(AircraftModel aircraft) async {
    try {
      await _firestore
          .collection(_Collections.aircrafts)
          .doc(aircraft.id)
          .update(aircraft.toMap());
      await fetchAllAircrafts();
      return true;
    } catch (e) {
      _aircraftsState = const Error('Error al actualizar aeronave');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAircraft(String id) async {
    try {
      await _firestore.collection(_Collections.aircrafts).doc(id).delete();
      await fetchAllAircrafts();
      return true;
    } catch (e) {
      _aircraftsState = const Error('Error al eliminar aeronave');
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // GATES CRUD
  // ──────────────────────────────────────────────

  Future<void> fetchAllGates() async {
    _gatesState = const Loading();
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(_Collections.gates)
          .orderBy('name')
          .get();
      _gatesState = Success(
        snapshot.docs
            .map((doc) => GateModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      _gatesState = const Error('Error al cargar puertas');
    }
    notifyListeners();
  }

  Future<bool> createGate(GateModel gate) async {
    try {
      final ref = _firestore.collection(_Collections.gates).doc(_uuid.v4());
      await ref.set(gate.copyWith(id: ref.id).toMap());
      await fetchAllGates();
      return true;
    } catch (e) {
      _gatesState = const Error('Error al crear puerta');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGate(GateModel gate) async {
    try {
      await _firestore
          .collection(_Collections.gates)
          .doc(gate.id)
          .update(gate.toMap());
      await fetchAllGates();
      return true;
    } catch (e) {
      _gatesState = const Error('Error al actualizar puerta');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteGate(String id) async {
    try {
      await _firestore.collection(_Collections.gates).doc(id).delete();
      await fetchAllGates();
      return true;
    } catch (e) {
      _gatesState = const Error('Error al eliminar puerta');
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // TERMINALS CRUD
  // ──────────────────────────────────────────────

  Future<void> fetchAllTerminals() async {
    _terminalsState = const Loading();
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(_Collections.terminals)
          .orderBy('name')
          .get();
      _terminalsState = Success(
        snapshot.docs
            .map((doc) => TerminalModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      _terminalsState = const Error('Error al cargar terminales');
    }
    notifyListeners();
  }

  Future<bool> createTerminal(TerminalModel terminal) async {
    try {
      final ref = _firestore.collection(_Collections.terminals).doc(_uuid.v4());
      await ref.set(terminal.copyWith(id: ref.id).toMap());
      await fetchAllTerminals();
      return true;
    } catch (e) {
      _terminalsState = const Error('Error al crear terminal');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTerminal(TerminalModel terminal) async {
    try {
      await _firestore
          .collection(_Collections.terminals)
          .doc(terminal.id)
          .update(terminal.toMap());
      await fetchAllTerminals();
      return true;
    } catch (e) {
      _terminalsState = const Error('Error al actualizar terminal');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTerminal(String id) async {
    try {
      await _firestore.collection(_Collections.terminals).doc(id).delete();
      await fetchAllTerminals();
      return true;
    } catch (e) {
      _terminalsState = const Error('Error al eliminar terminal');
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // EMPLOYEES CRUD
  // ──────────────────────────────────────────────

  Future<void> fetchAllEmployees() async {
    _employeesState = const Loading();
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(_Collections.employees)
          .orderBy('firstName')
          .get();
      _employeesState = Success(
        snapshot.docs
            .map((doc) => EmployeeModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      _employeesState = const Error('Error al cargar empleados');
    }
    notifyListeners();
  }

  Future<bool> createEmployee(EmployeeModel employee) async {
    try {
      final ref = _firestore.collection(_Collections.employees).doc(_uuid.v4());
      final data = employee.copyWith(id: ref.id).toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(data);
      await fetchAllEmployees();
      return true;
    } catch (e) {
      _employeesState = const Error('Error al crear empleado');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmployee(EmployeeModel employee) async {
    try {
      await _firestore
          .collection(_Collections.employees)
          .doc(employee.id)
          .update(employee.toMap());
      await fetchAllEmployees();
      return true;
    } catch (e) {
      _employeesState = const Error('Error al actualizar empleado');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      await _firestore.collection(_Collections.employees).doc(id).delete();
      await fetchAllEmployees();
      return true;
    } catch (e) {
      _employeesState = const Error('Error al eliminar empleado');
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // PASSENGERS CRUD
  // ──────────────────────────────────────────────

  Future<void> fetchAllPassengers() async {
    _passengersState = const Loading();
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(_Collections.passengers)
          .orderBy('lastName')
          .get();
      _passengersState = Success(
        snapshot.docs
            .map((doc) => PassengerModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      _passengersState = const Error('Error al cargar pasajeros');
    }
    notifyListeners();
  }

  Future<bool> createPassenger(PassengerModel passenger) async {
    try {
      final ref = _firestore
          .collection(_Collections.passengers)
          .doc(_uuid.v4());
      final data = passenger.copyWith(id: ref.id).toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(data);
      await fetchAllPassengers();
      return true;
    } catch (e) {
      _passengersState = const Error('Error al crear pasajero');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassenger(PassengerModel passenger) async {
    try {
      await _firestore
          .collection(_Collections.passengers)
          .doc(passenger.id)
          .update(passenger.toMap());
      await fetchAllPassengers();
      return true;
    } catch (e) {
      _passengersState = const Error('Error al actualizar pasajero');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePassenger(String id) async {
    try {
      await _firestore.collection(_Collections.passengers).doc(id).delete();
      await fetchAllPassengers();
      return true;
    } catch (e) {
      _passengersState = const Error('Error al eliminar pasajero');
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // MAINTENANCE CRUD
  // ──────────────────────────────────────────────

  Future<void> fetchAllMaintenanceLogs() async {
    _maintenanceState = const Loading();
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(_Collections.maintenance)
          .orderBy('startDate', descending: true)
          .get();
      _maintenanceState = Success(
        snapshot.docs
            .map((doc) => MaintenanceLogModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      _maintenanceState = const Error(
        'Error al cargar registros de mantenimiento',
      );
    }
    notifyListeners();
  }

  Future<bool> createMaintenanceLog(MaintenanceLogModel log) async {
    try {
      final ref = _firestore
          .collection(_Collections.maintenance)
          .doc(_uuid.v4());
      await ref.set(log.copyWith(id: ref.id).toMap());
      await fetchAllMaintenanceLogs();
      return true;
    } catch (e) {
      _maintenanceState = const Error(
        'Error al crear registro de mantenimiento',
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMaintenanceLog(MaintenanceLogModel log) async {
    try {
      await _firestore
          .collection(_Collections.maintenance)
          .doc(log.id)
          .update(log.toMap());
      await fetchAllMaintenanceLogs();
      return true;
    } catch (e) {
      _maintenanceState = const Error(
        'Error al actualizar registro de mantenimiento',
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMaintenanceLog(String id) async {
    try {
      await _firestore.collection(_Collections.maintenance).doc(id).delete();
      await fetchAllMaintenanceLogs();
      return true;
    } catch (e) {
      _maintenanceState = const Error(
        'Error al eliminar registro de mantenimiento',
      );
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // USERS CRUD
  // ──────────────────────────────────────────────

  static const String _firebaseWebApiKey =
      'AIzaSyDkMXRcs3p8fijmqBLMffCH4cyJGPTFmMI';

  Future<bool> createUser(
    String email,
    String password,
    String displayName,
    UserRole role,
  ) async {
    try {
      final uid = await _createFirebaseAuthUser(email, password);
      if (uid == null) return false;

      await _firestore
          .collection(_Collections.users)
          .doc(uid)
          .set(
            UserModel(
              uid: uid,
              email: email,
              displayName: displayName,
              role: role,
              isActive: true,
              createdAt: DateTime.now(),
            ).toMap(),
          );

      await fetchAllUsers();
      return true;
    } catch (e) {
      debugPrint('Error inesperado al crear usuario: $e');
      _usersState = const Error(
        'Error al crear usuario. Verifica la conexión.',
      );
      notifyListeners();
      return false;
    }
  }

  Future<String?> _createFirebaseAuthUser(String email, String password) async {
    const url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseWebApiKey';
    final body = jsonEncode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson.containsKey('error')) {
        final errorMsg = responseJson['error']['message'] as String? ?? 'ERROR';
        _usersState = Error(_translateAuthError(errorMsg));
        notifyListeners();
        return null;
      }

      return responseJson['localId'] as String?;
    } catch (e) {
      debugPrint('HTTP error creating user: $e');
      _usersState = const Error('Error de red. Verifica tu conexión.');
      notifyListeners();
      return null;
    }
  }

  String _translateAuthError(String code) {
    if (code.contains('EMAIL_EXISTS')) return 'Este correo ya está registrado';
    if (code.contains('INVALID_EMAIL')) return 'Correo electrónico inválido';
    if (code.contains('WEAK_PASSWORD'))
      return 'Contraseña débil (mínimo 6 caracteres)';
    if (code.contains('TOO_MANY_ATTEMPTS'))
      return 'Demasiados intentos. Espera un momento.';
    if (code.contains('OPERATION_NOT_ALLOWED'))
      return 'Registro no habilitado en Firebase';
    return 'Error al crear usuario ($code)';
  }

  Future<void> fetchAllUsers() async {
    _usersState = const Loading();
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection(_Collections.users)
          .orderBy('createdAt', descending: true)
          .get();
      _usersState = Success(
        snapshot.docs
            .map((doc) => UserModel.fromMap(doc.id, doc.data()))
            .toList(),
      );
    } catch (e) {
      _usersState = const Error('Error al cargar usuarios');
    }
    notifyListeners();
  }

  Future<bool> updateUserRole(String uid, UserRole role) async {
    try {
      await _firestore.collection(_Collections.users).doc(uid).update({
        'role': role.value,
      });
      await fetchAllUsers();
      return true;
    } catch (e) {
      _usersState = const Error('Error al actualizar rol de usuario');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      await _firestore.collection(_Collections.users).doc(user.uid).update({
        'displayName': user.displayName,
        'role': user.role.value,
        'isActive': user.isActive,
      });
      await fetchAllUsers();
      return true;
    } catch (e) {
      _usersState = const Error('Error al actualizar usuario');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String uid) async {
    try {
      await _firestore.collection(_Collections.users).doc(uid).delete();
      await fetchAllUsers();
      return true;
    } catch (e) {
      _usersState = const Error('Error al eliminar usuario');
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // DASHBOARD
  // ──────────────────────────────────────────────

  Future<Map<String, int>> loadDashboardCounts() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(hours: 24));

      final flightsTodaySnap = await _firestore
          .collection(_Collections.flights)
          .where(
            'departureTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('departureTime', isLessThan: Timestamp.fromDate(endOfDay))
          .count()
          .get();

      final passengersSnap = await _firestore
          .collection(_Collections.passengers)
          .count()
          .get();

      final activeGatesSnap = await _firestore
          .collection(_Collections.gates)
          .where('status', isEqualTo: 'occupied')
          .count()
          .get();

      final openIncidentsSnap = await _firestore
          .collection(_Collections.maintenance)
          .where('status', whereIn: ['scheduled', 'in_progress'])
          .count()
          .get();

      final bookingsSnap = await _firestore
          .collection(_Collections.bookings)
          .count()
          .get();

      return {
        'flightsToday': flightsTodaySnap.count ?? 0,
        'passengers': passengersSnap.count ?? 0,
        'activeGates': activeGatesSnap.count ?? 0,
        'openIncidents': openIncidentsSnap.count ?? 0,
        'bookings': bookingsSnap.count ?? 0,
      };
    } catch (e) {
      return {};
    }
  }

  // ──────────────────────────────────────────────
  // REPORTS
  // ──────────────────────────────────────────────

  Future<Map<String, int>> flightsByDayOfWeek() async {
    try {
      final snapshot = await _firestore.collection(_Collections.flights).get();
      final counts = <String, int>{
        'Lun': 0,
        'Mar': 0,
        'Mié': 0,
        'Jue': 0,
        'Vie': 0,
        'Sáb': 0,
        'Dom': 0,
      };
      final labels = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final ts = data['departureTime'] as Timestamp?;
        if (ts != null) {
          final day = ts.toDate().weekday;
          counts[labels[day]] = (counts[labels[day]] ?? 0) + 1;
        }
      }
      return counts;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, int>> bookingsByMonth() async {
    try {
      final snapshot = await _firestore.collection(_Collections.bookings).get();
      final counts = <String, int>{
        'Ene': 0,
        'Feb': 0,
        'Mar': 0,
        'Abr': 0,
        'May': 0,
        'Jun': 0,
        'Jul': 0,
        'Ago': 0,
        'Sep': 0,
        'Oct': 0,
        'Nov': 0,
        'Dic': 0,
      };
      final labels = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final ts = data['createdAt'] as Timestamp?;
        if (ts != null) {
          final month = ts.toDate().month - 1;
          counts[labels[month]] = (counts[labels[month]] ?? 0) + 1;
        }
      }
      return counts;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, int>> flightStatusDistribution() async {
    try {
      final snapshot = await _firestore.collection(_Collections.flights).get();
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'unknown';
        counts[status] = (counts[status] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      return {};
    }
  }

  Future<List<MapEntry<String, int>>> topRoutes() async {
    try {
      final snapshot = await _firestore.collection(_Collections.bookings).get();
      final routeCounts = <String, int>{};
      for (final doc in snapshot.docs) {
        final origin = doc.data()['originCode'] as String? ?? '';
        final destination = doc.data()['destinationCode'] as String? ?? '';
        final route = '$origin → $destination';
        routeCounts[route] = (routeCounts[route] ?? 0) + 1;
      }
      final sorted = routeCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sorted.take(5).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateFlightStatus(String flightId, String status) async {
    try {
      await _firestore.collection(_Collections.flights).doc(flightId).update({
        'status': status,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
