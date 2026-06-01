import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../shared/models/user_model.dart';

Future<void> seedFirestoreData() async {
  if (!kDebugMode) return;

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  final seedUsers = [
    {
      'email': 'admin@aeropuerto.com',
      'password': 'Test123!',
      'model': UserModel(
        uid: '',
        email: 'admin@aeropuerto.com',
        displayName: 'Carlos Admin',
        role: UserRole.admin,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    },
    {
      'email': 'staff@aeropuerto.com',
      'password': 'Test123!',
      'model': UserModel(
        uid: '',
        email: 'staff@aeropuerto.com',
        displayName: 'Maria Staff',
        role: UserRole.staff,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    },
    {
      'email': 'pasajero@test.com',
      'password': 'Test123!',
      'model': UserModel(
        uid: '',
        email: 'pasajero@test.com',
        displayName: 'Juan Pasajero',
        role: UserRole.passenger,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    },
  ];

  String? adminUid;

  for (final entry in seedUsers) {
    final email = entry['email'] as String;
    final password = entry['password'] as String;
    final model = entry['model'] as UserModel;

    String? uid;

    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      uid = cred.user!.uid;
      debugPrint('Usuario creado: $email');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        debugPrint('Usuario ya existe: $email');
        try {
          final cred = await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          uid = cred.user!.uid;
        } catch (_) {
          debugPrint('No se pudo obtener UID de $email');
        }
      } else {
        debugPrint('Error Auth $email: $e');
      }
    }

    if (uid == null) continue;

    if (model.role == UserRole.admin) adminUid = uid;

    try {
      await firestore
          .collection('users')
          .doc(uid)
          .set(model.copyWith(uid: uid).toMap(), SetOptions(merge: true));
      debugPrint('Documento users/$uid creado/actualizado');
    } catch (e) {
      debugPrint('Error escribiendo users/$uid: $e');
    }
  }

  if (adminUid == null) {
    try {
      final cred = await auth.signInWithEmailAndPassword(
        email: 'admin@aeropuerto.com',
        password: 'Test123!',
      );
      adminUid = cred.user!.uid;
      debugPrint('Sesión admin iniciada para seed');
    } catch (e) {
      debugPrint('No se pudo iniciar sesión como admin: $e');
      return;
    }
  } else {
    final currentUser = auth.currentUser;
    if (currentUser?.email != 'admin@aeropuerto.com') {
      try {
        await auth.signInWithEmailAndPassword(
          email: 'admin@aeropuerto.com',
          password: 'Test123!',
        );
        debugPrint('Reautenticado como admin para seed');
      } catch (e) {
        debugPrint('Error al reautenticar como admin: $e');
      }
    }
  }

  final airlines = {
    'aeromexico': {
      'name': 'Aeroméxico',
      'iataCode': 'AM',
      'logoUrl': '',
      'country': 'México',
      'isActive': true,
    },
    'volaris': {
      'name': 'Volaris',
      'iataCode': 'Y4',
      'logoUrl': '',
      'country': 'México',
      'isActive': true,
    },
    'interjet': {
      'name': 'Interjet',
      'iataCode': '4O',
      'logoUrl': '',
      'country': 'México',
      'isActive': false,
    },
  };

  for (final entry in airlines.entries) {
    try {
      await firestore
          .collection('airlines')
          .doc(entry.key)
          .set(Map<String, dynamic>.from(entry.value), SetOptions(merge: true));
      debugPrint('Aerolínea ${entry.key} OK');
    } catch (e) {
      debugPrint('Error creando aerolínea ${entry.key}: $e');
    }
  }

  final terminals = {
    'terminal-1': {'name': 'Terminal 1', 'code': 'T1', 'gatesCount': 3},
    'terminal-2': {'name': 'Terminal 2', 'code': 'T2', 'gatesCount': 3},
  };

  for (final entry in terminals.entries) {
    try {
      await firestore
          .collection('terminals')
          .doc(entry.key)
          .set(Map<String, dynamic>.from(entry.value), SetOptions(merge: true));
      debugPrint('Terminal ${entry.key} OK');
    } catch (e) {
      debugPrint('Error creando terminal ${entry.key}: $e');
    }
  }

  final gates = {
    'gate-a1': {
      'terminalId': 'terminal-1',
      'terminalName': 'Terminal 1',
      'name': 'A1',
      'status': 'available',
      'currentFlightId': '',
      'currentFlightNumber': '',
    },
    'gate-a2': {
      'terminalId': 'terminal-1',
      'terminalName': 'Terminal 1',
      'name': 'A2',
      'status': 'available',
      'currentFlightId': '',
      'currentFlightNumber': '',
    },
    'gate-a3': {
      'terminalId': 'terminal-1',
      'terminalName': 'Terminal 1',
      'name': 'A3',
      'status': 'maintenance',
      'currentFlightId': '',
      'currentFlightNumber': '',
    },
    'gate-b1': {
      'terminalId': 'terminal-2',
      'terminalName': 'Terminal 2',
      'name': 'B1',
      'status': 'available',
      'currentFlightId': '',
      'currentFlightNumber': '',
    },
    'gate-b2': {
      'terminalId': 'terminal-2',
      'terminalName': 'Terminal 2',
      'name': 'B2',
      'status': 'available',
      'currentFlightId': '',
      'currentFlightNumber': '',
    },
    'gate-b3': {
      'terminalId': 'terminal-2',
      'terminalName': 'Terminal 2',
      'name': 'B3',
      'status': 'occupied',
      'currentFlightId': 'flight-003',
      'currentFlightNumber': 'AM250',
    },
  };

  for (final entry in gates.entries) {
    try {
      await firestore
          .collection('gates')
          .doc(entry.key)
          .set(Map<String, dynamic>.from(entry.value), SetOptions(merge: true));
      debugPrint('Puerta ${entry.key} OK');
    } catch (e) {
      debugPrint('Error creando puerta ${entry.key}: $e');
    }
  }

  // Vuelos siempre con fecha de HOY para que aparezcan en pantalla
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final flights = {
    'flight-001': {
      'flightNumber': 'AM100',
      'airlineId': 'aeromexico',
      'airlineName': 'Aeroméxico',
      'aircraftId': '',
      'originCode': 'MEX',
      'originName': 'Ciudad de México',
      'destinationCode': 'CUN',
      'destinationName': 'Cancún',
      'departureTime': Timestamp.fromDate(
        today.add(const Duration(hours: 7, minutes: 30)),
      ),
      'arrivalTime': Timestamp.fromDate(
        today.add(const Duration(hours: 10, minutes: 15)),
      ),
      'status': 'scheduled',
      'gateId': 'gate-a1',
      'gateName': 'A1',
      'basePrice': 2800.0,
      'availableSeats': 42,
      'totalSeats': 150,
      'createdAt': Timestamp.fromDate(now),
    },
    'flight-002': {
      'flightNumber': 'Y4200',
      'airlineId': 'volaris',
      'airlineName': 'Volaris',
      'aircraftId': '',
      'originCode': 'MEX',
      'originName': 'Ciudad de México',
      'destinationCode': 'GDL',
      'destinationName': 'Guadalajara',
      'departureTime': Timestamp.fromDate(
        today.add(const Duration(hours: 9, minutes: 0)),
      ),
      'arrivalTime': Timestamp.fromDate(
        today.add(const Duration(hours: 10, minutes: 20)),
      ),
      'status': 'boarding',
      'gateId': 'gate-a2',
      'gateName': 'A2',
      'basePrice': 1500.0,
      'availableSeats': 8,
      'totalSeats': 120,
      'createdAt': Timestamp.fromDate(now),
    },
    'flight-003': {
      'flightNumber': 'AM250',
      'airlineId': 'aeromexico',
      'airlineName': 'Aeroméxico',
      'aircraftId': '',
      'originCode': 'CUN',
      'originName': 'Cancún',
      'destinationCode': 'MEX',
      'destinationName': 'Ciudad de México',
      'departureTime': Timestamp.fromDate(
        today.add(const Duration(hours: 11, minutes: 45)),
      ),
      'arrivalTime': Timestamp.fromDate(
        today.add(const Duration(hours: 14, minutes: 30)),
      ),
      'status': 'delayed',
      'gateId': 'gate-b3',
      'gateName': 'B3',
      'basePrice': 3100.0,
      'availableSeats': 25,
      'totalSeats': 150,
      'createdAt': Timestamp.fromDate(now),
    },
    'flight-004': {
      'flightNumber': '4O500',
      'airlineId': 'interjet',
      'airlineName': 'Interjet',
      'aircraftId': '',
      'originCode': 'MEX',
      'originName': 'Ciudad de México',
      'destinationCode': 'MTY',
      'destinationName': 'Monterrey',
      'departureTime': Timestamp.fromDate(
        today.add(const Duration(hours: 14, minutes: 0)),
      ),
      'arrivalTime': Timestamp.fromDate(
        today.add(const Duration(hours: 15, minutes: 40)),
      ),
      'status': 'scheduled',
      'gateId': '',
      'gateName': '',
      'basePrice': 2200.0,
      'availableSeats': 60,
      'totalSeats': 100,
      'createdAt': Timestamp.fromDate(now),
    },
    'flight-005': {
      'flightNumber': 'Y4550',
      'airlineId': 'volaris',
      'airlineName': 'Volaris',
      'aircraftId': '',
      'originCode': 'GDL',
      'originName': 'Guadalajara',
      'destinationCode': 'CUN',
      'destinationName': 'Cancún',
      'departureTime': Timestamp.fromDate(
        today.add(const Duration(hours: 16, minutes: 30)),
      ),
      'arrivalTime': Timestamp.fromDate(
        today.add(const Duration(hours: 19, minutes: 55)),
      ),
      'status': 'scheduled',
      'gateId': '',
      'gateName': '',
      'basePrice': 3500.0,
      'availableSeats': 90,
      'totalSeats': 120,
      'createdAt': Timestamp.fromDate(now),
    },
  };

  for (final entry in flights.entries) {
    try {
      // set() sin merge para SIEMPRE actualizar las fechas a HOY
      await firestore
          .collection('flights')
          .doc(entry.key)
          .set(Map<String, dynamic>.from(entry.value));
      debugPrint('Vuelo ${entry.key} OK');
    } catch (e) {
      debugPrint('Error creando vuelo ${entry.key}: $e');
    }
  }

  try {
    final existing = await firestore.collection('notifications').limit(1).get();
    if (existing.docs.isEmpty) {
      final notifications = [
        {
          'type': 'info',
          'title': 'Bienvenido a Aeropuerto MGT',
          'body':
              'Tu aplicación de gestión aeroportuaria. Mantente informado de todos tus vuelos.',
          'targetAudience': ['all'],
          'createdAt': Timestamp.fromDate(now),
        },
        {
          'type': 'flight',
          'title': 'Vuelo AM250 retrasado',
          'body':
              'El vuelo AM250 con destino a Ciudad de México presenta un retraso de 30 minutos.',
          'flightId': 'flight-003',
          'targetAudience': ['all'],
          'createdAt': Timestamp.fromDate(
            now.subtract(const Duration(hours: 1)),
          ),
        },
      ];

      for (final notification in notifications) {
        await firestore
            .collection('notifications')
            .add(Map<String, dynamic>.from(notification));
      }
      debugPrint('Notificaciones creadas OK');
    } else {
      debugPrint('Notificaciones ya existen, omitiendo');
    }
  } catch (e) {
    debugPrint('Error con notificaciones: $e');
  }

  try {
    await auth.signOut();
    debugPrint('Sesión cerrada después del seed completo');
  } catch (_) {}

  debugPrint('╔═══════════════════════════════════════╗');
  debugPrint('║   ✅ SEED COMPLETADO CORRECTAMENTE    ║');
  debugPrint('╠═══════════════════════════════════════╣');
  debugPrint('║  admin@aeropuerto.com  / Test123!     ║');
  debugPrint('║  staff@aeropuerto.com  / Test123!     ║');
  debugPrint('║  pasajero@test.com     / Test123!     ║');
  debugPrint('╚═══════════════════════════════════════╝');
}
