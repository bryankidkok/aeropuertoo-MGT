import 'package:firebase_core/firebase_core.dart';

class ErrorHandler {
  static String getFirebaseErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'No tienes permisos para realizar esta acción';
      case 'not-found':
        return 'El recurso solicitado no existe';
      case 'unavailable':
        return 'El servicio no está disponible en este momento. Intenta más tarde';
      case 'cancelled':
        return 'La operación fue cancelada';
      case 'unauthenticated':
        return 'Debes iniciar sesión para continuar';
      case 'quota-exceeded':
        return 'Se ha excedido el límite de solicitudes. Intenta más tarde';
      case 'already-exists':
        return 'El registro ya existe';
      case 'deadline-exceeded':
        return 'La operación tardó demasiado. Verifica tu conexión';
      case 'failed-precondition':
        return 'La operación no se pudo completar por el estado actual del sistema';
      case 'internal':
        return 'Error interno del servidor. Intenta más tarde';
      case 'invalid-argument':
        return 'Los datos proporcionados no son válidos';
      case 'resource-exhausted':
        return 'Recursos insuficientes. Intenta más tarde';
      case 'aborted':
        return 'La operación fue abortada';
      case 'out-of-range':
        return 'El valor está fuera del rango permitido';
      case 'data-loss':
        return 'Se ha producido una pérdida de datos';
      case 'unknown':
        return 'Error desconocido. Intenta de nuevo';
      default:
        return 'Error: ${e.message ?? e.code}';
    }
  }

  static String getGenericError(dynamic error) {
    if (error is FirebaseException) {
      return getFirebaseErrorMessage(error);
    }
    if (error is FormatException) {
      return 'Formato de datos inválido';
    }
    return 'Ha ocurrido un error inesperado';
  }
}
