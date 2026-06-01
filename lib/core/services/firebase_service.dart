import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  factory FirebaseService() => _instance;
  FirebaseService._();

  bool _initialized = false;
  String? _initError;

  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initialized = true;
      _initError = null;
      return true;
    } catch (e) {
      _initialized = false;
      _initError = e.toString();
      debugPrint('Firebase init error: $_initError');
      return false;
    }
  }

  bool get isInitialized => _initialized;
  String? get initError => _initError;
}
