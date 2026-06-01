import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/result_state.dart';
import '../models/flight_model.dart';

class FlightProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ResultState<List<FlightModel>> _state = const Idle();
  FlightModel? _selectedFlight;
  StreamSubscription? _snapshotsSubscription;
  DateTime? _lastFetch;
  bool _isFiltered = false;

  ResultState<List<FlightModel>> get state => _state;
  FlightModel? get selectedFlight => _selectedFlight;
  List<FlightModel> get flights => _state is Success<List<FlightModel>>
      ? (_state as Success<List<FlightModel>>).data
      : [];
  bool get isLoading => _state is Loading;
  bool get hasData => _state is Success<List<FlightModel>>;
  bool get isFiltered => _isFiltered;
  bool get isListening => _snapshotsSubscription != null;
  String? get errorMessage => _state is Error<List<FlightModel>>
      ? (_state as Error<List<FlightModel>>).message
      : null;

  @override
  void dispose() {
    _snapshotsSubscription?.cancel();
    super.dispose();
  }

  void _startRealtimeListener() {
    _snapshotsSubscription?.cancel();
    // Mostrar spinner inmediatamente si no hay datos aún
    if (!hasData) {
      _state = const Loading();
      notifyListeners();
    }
    _snapshotsSubscription = _firestore
        .collection('flights')
        .orderBy('departureTime', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
            final list = snapshot.docs.map((doc) {
              return FlightModel.fromMap(doc.id, doc.data());
            }).toList();
            _state = Success(list);
            _isFiltered = false;
            notifyListeners();
          },
          onError: (e) {
            _state = const Error('Error en la conexión en tiempo real');
            notifyListeners();
          },
        );
  }

  Future<void> fetchFlights({bool force = false}) async {
    _snapshotsSubscription?.cancel();
    final now = DateTime.now();
    if (!force &&
        !_isFiltered &&
        hasData &&
        _lastFetch != null &&
        now.difference(_lastFetch!).inMinutes < 2) {
      return;
    }

    _state = const Loading();
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('flights')
          .orderBy('departureTime', descending: false)
          .get();
      final list = snapshot.docs.map((doc) {
        return FlightModel.fromMap(doc.id, doc.data());
      }).toList();
      _state = Success(list);
      _lastFetch = DateTime.now();
      _isFiltered = false;
    } catch (e) {
      _state = const Error('Error al cargar vuelos');
    }
    notifyListeners();
  }

  Future<void> fetchFlightById(String id) async {
    _selectedFlight = null;
    notifyListeners();

    try {
      final doc = await _firestore.collection('flights').doc(id).get();
      if (!doc.exists) {
        _selectedFlight = null;
        notifyListeners();
        return;
      }
      _selectedFlight = FlightModel.fromMap(doc.id, doc.data()!);
    } catch (e) {
      _selectedFlight = null;
    }
    notifyListeners();
  }

  Future<void> searchFlights({
    String? origin,
    String? destination,
    DateTime? date,
  }) async {
    _snapshotsSubscription?.cancel();
    _state = const Loading();
    notifyListeners();

    try {
      Query<Map<String, dynamic>> query = _firestore.collection('flights');
      if (origin != null && origin.isNotEmpty) {
        query = query.where('originCode', isEqualTo: origin.toUpperCase());
      }
      if (destination != null && destination.isNotEmpty) {
        query = query.where(
          'destinationCode',
          isEqualTo: destination.toUpperCase(),
        );
      }
      query = query.orderBy('departureTime');

      final snapshot = await query.get();
      var list = snapshot.docs.map((doc) {
        return FlightModel.fromMap(doc.id, doc.data());
      }).toList();

      if (date != null) {
        final start = DateTime(date.year, date.month, date.day);
        final end = start.add(const Duration(days: 1));
        list = list
            .where(
              (f) =>
                  f.departureTime.isAfter(start) &&
                  f.departureTime.isBefore(end),
            )
            .toList();
      }

      _state = Success(list);
      _isFiltered = true;
    } catch (e) {
      _state = const Error('Error al buscar vuelos');
    }
    notifyListeners();
  }

  Future<void> filterByStatus(FlightStatus status) async {
    _snapshotsSubscription?.cancel();
    _state = const Loading();
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('flights')
          .where('status', isEqualTo: status.value)
          .orderBy('departureTime')
          .get();
      final list = snapshot.docs.map((doc) {
        return FlightModel.fromMap(doc.id, doc.data());
      }).toList();
      _state = Success(list);
    } catch (e) {
      _state = const Error('Error al filtrar vuelos');
    }
    notifyListeners();
  }

  void startListening() => _startRealtimeListener();
  void stopListening() => _snapshotsSubscription?.cancel();
}
