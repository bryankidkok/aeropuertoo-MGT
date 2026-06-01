class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email es requerido';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Email inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Contraseña es requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? required(String? value, [String field = 'Campo']) {
    if (value == null || value.trim().isEmpty) return '$field es requerido';
    return null;
  }

  static String? flightCode(String? value) {
    if (value == null || value.isEmpty) return 'Código de vuelo requerido';
    final codeRegex = RegExp(r'^[A-Z]{2}\d{3,4}$');
    if (!codeRegex.hasMatch(value)) return 'Formato: AA1234';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Teléfono requerido';
    final phoneRegex = RegExp(r'^\+?\d{7,15}$');
    if (!phoneRegex.hasMatch(value)) return 'Teléfono inválido';
    return null;
  }
}
