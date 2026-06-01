import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/result_state.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  ResultState<List<BookingModel>> _state = const Idle();

  ResultState<List<BookingModel>> get state => _state;
  List<BookingModel> get bookings => _state is Success<List<BookingModel>>
      ? (_state as Success<List<BookingModel>>).data
      : [];
  bool get isLoading => _state is Loading;
  String? get errorMessage => _state is Error<List<BookingModel>>
      ? (_state as Error<List<BookingModel>>).message
      : null;

  /// Carga las reservas del pasajero — sin orderBy para evitar índice compuesto
  Future<void> fetchBookingsByPassenger(String passengerId) async {
    _state = const Loading();
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('passengerId', isEqualTo: passengerId)
          .get();

      final list = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
          .toList();

      // Ordenar del más reciente al más antiguo en memoria
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _state = Success(list);
    } catch (e) {
      debugPrint('Error fetchBookingsByPassenger: $e');
      _state = const Error('Error al cargar reservas');
    }
    notifyListeners();
  }

  Future<void> fetchAllBookings() async {
    _state = const Loading();
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .get();
      final list = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
          .toList();
      _state = Success(list);
    } catch (e) {
      debugPrint('Error fetchAllBookings: $e');
      _state = const Error('Error al cargar todas las reservas');
    }
    notifyListeners();
  }

  Future<bool> createBooking(BookingModel booking) async {
    try {
      final ref = _firestore.collection('bookings').doc(_uuid.v4());
      final data = booking
          .copyWith(id: ref.id, createdAt: DateTime.now())
          .toMap();
      data['createdAt'] = FieldValue.serverTimestamp();

      // Guardar la reserva directamente
      await ref.set(data);

      // Actualizar asientos disponibles (sin bloquear si falla)
      try {
        final flightRef = _firestore
            .collection('flights')
            .doc(booking.flightId);
        await _firestore.runTransaction((tx) async {
          final flightDoc = await tx.get(flightRef);
          if (flightDoc.exists) {
            final current =
                (flightDoc.data()?['availableSeats'] as num?)?.toInt() ?? 0;
            if (current > 0) {
              tx.update(flightRef, {'availableSeats': current - 1});
            }
          }
        });
      } catch (e) {
        debugPrint('Aviso: no se actualizaron asientos: $e');
      }

      // Recargar solo las reservas del pasajero (sin orderBy para evitar índice)
      await fetchBookingsByPassenger(booking.passengerId);
      return true;
    } catch (e) {
      debugPrint('Error createBooking: $e');
      _state = const Error('Error al crear reserva');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBookingStatus(String id, BookingStatus status) async {
    try {
      await _firestore.collection('bookings').doc(id).update({
        'status': status.value,
      });
      return true;
    } catch (e) {
      _state = const Error('Error al actualizar estado de reserva');
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(String id, String passengerId) async {
    try {
      await _firestore.collection('bookings').doc(id).update({
        'status': BookingStatus.cancelled.value,
      });
      await fetchBookingsByPassenger(passengerId);
      return true;
    } catch (e) {
      _state = const Error('Error al cancelar reserva');
      notifyListeners();
      return false;
    }
  }
}
