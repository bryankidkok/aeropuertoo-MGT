import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/result_state.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ResultState<UserModel> _state = const Idle();

  ResultState<UserModel> get state => _state;

  bool get isAdmin =>
      _state is Success<UserModel> &&
      (_state as Success<UserModel>).data.role == UserRole.admin;
  bool get isStaff =>
      _state is Success<UserModel> &&
      (_state as Success<UserModel>).data.role == UserRole.staff;
  bool get isPassenger =>
      _state is Success<UserModel> &&
      (_state as Success<UserModel>).data.role == UserRole.passenger;
  bool get isAuthenticated => _state is Success<UserModel>;
  bool get isLoading => _state is Loading;
  String? get errorMessage =>
      _state is Error<UserModel> ? (_state as Error<UserModel>).message : null;
  UserModel? get user =>
      _state is Success<UserModel> ? (_state as Success<UserModel>).data : null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser != null) {
      _fetchUserData(firebaseUser.uid);
    } else {
      _state = const Idle();
      notifyListeners();
    }
  }

  Future<void> _fetchUserData(String uid) async {
    // Si ya tenemos sesión válida, no cambiar a Loading para no disparar
    // redirecciones del router mientras se recarga en segundo plano.
    final alreadyAuthenticated = _state is Success<UserModel>;
    if (!alreadyAuthenticated) {
      _state = const Loading();
      notifyListeners();
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        // Si ya hay sesión activa (ej. admin creando usuarios), no degradar el rol.
        if (alreadyAuthenticated) return;
        final currentUser = _auth.currentUser;
        final email = currentUser?.email ?? '';
        final name = currentUser?.displayName;
        final fallbackName = (name != null && name.isNotEmpty)
            ? name
            : email.split('@').first;
        final fallbackModel = UserModel(
          uid: uid,
          email: email,
          displayName: fallbackName,
          role: UserRole.passenger,
          isActive: true,
          createdAt: DateTime.now(),
        );

        // Intentar crear el documento si no existe
        try {
          await _firestore
              .collection('users')
              .doc(uid)
              .set(fallbackModel.toMap(), SetOptions(merge: true));
        } catch (e) {
          debugPrint('No se pudo crear documento fallback para $uid: $e');
          // Continuar de todas formas con el modelo en memoria
        }

        _state = Success(fallbackModel);
        notifyListeners();
        return;
      }

      final user = UserModel.fromMap(uid, doc.data()!);

      if (!user.isActive) {
        _state = const Error('Cuenta desactivada. Contacta al administrador.');
        await _auth.signOut();
        notifyListeners();
        return;
      }

      _state = Success(user);
    } on FirebaseException catch (e) {
      // permission-denied u otro error de Firestore
      debugPrint(
        'FirebaseException en _fetchUserData: ${e.code} - ${e.message}',
      );
      if (e.code == 'permission-denied') {
        // Último recurso: usar datos básicos del FirebaseAuth user
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          _state = Success(
            UserModel(
              uid: uid,
              email: currentUser.email ?? '',
              displayName:
                  (currentUser.displayName != null &&
                      currentUser.displayName!.isNotEmpty)
                  ? currentUser.displayName!
                  : 'Usuario',
              role: UserRole.passenger,
              isActive: true,
              createdAt: DateTime.now(),
            ),
          );
        } else {
          _state = const Error('Sin permisos para cargar perfil.');
        }
      } else {
        if (alreadyAuthenticated) return;
        _state = const Error('Error de conexión. Verifica tu internet.');
      }
    } catch (e) {
      debugPrint('Error inesperado en _fetchUserData: $e');
      if (alreadyAuthenticated) return;
      _state = const Error('Error inesperado al cargar perfil.');
    } finally {
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _state = const Loading();
    notifyListeners();

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = result.user?.uid;
      if (uid == null) {
        _state = const Error('Error al iniciar sesión');
        notifyListeners();
        return;
      }
      // _onAuthStateChanged se disparará automáticamente y llamará _fetchUserData
      // pero también lo llamamos directamente para feedback inmediato
      await _fetchUserData(uid);
    } on FirebaseAuthException catch (e) {
      _state = Error(_mapAuthError(e.code));
      notifyListeners();
    } catch (e) {
      _state = const Error('Error de conexión. Intenta de nuevo.');
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    _state = const Idle();
    notifyListeners();
  }

  Future<void> checkAuthState() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _fetchUserData(currentUser.uid);
    } else {
      _state = const Idle();
      notifyListeners();
    }
  }

  Future<UserRole?> getCurrentUserRole() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!doc.exists) return null;
      final roleStr = doc.data()?['role'] as String?;
      return roleStr != null ? UserRoleX.fromString(roleStr) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    _state = const Loading();
    notifyListeners();

    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = result.user!.uid;
      final userModel = UserModel(
        uid: uid,
        email: email.trim(),
        displayName: displayName.trim(),
        role: UserRole.passenger,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Guardar en Firestore (el usuario está autenticado, debe poder escribir su propio doc)
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(userModel.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error guardando Firestore en signUp: $e');
        // Continuar de todas formas — el usuario puede usar la app
      }

      _state = Success(userModel);
    } on FirebaseAuthException catch (e) {
      _state = Error(_mapAuthError(e.code));
    } catch (e) {
      _state = const Error('Error al crear cuenta. Intenta de nuevo.');
    }
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    _state = const Loading();
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _state = Success(
        user ??
            UserModel(
              uid: '',
              email: email,
              displayName: '',
              isActive: true,
              createdAt: DateTime.now(),
            ),
      );
    } on FirebaseAuthException catch (e) {
      _state = Error(_mapAuthError(e.code));
    } catch (e) {
      _state = const Error('Error al enviar correo de recuperación');
    }
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica email y contraseña.';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Cuenta desactivada';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos.';
      case 'network-request-failed':
        return 'Sin conexión. Verifica tu internet.';
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      default:
        return 'Error de autenticación ($code)';
    }
  }
}
