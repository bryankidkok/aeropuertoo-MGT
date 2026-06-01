import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';

String _roleLabel(UserRole r) {
  switch (r) {
    case UserRole.admin:
      return 'Administrador';
    case UserRole.staff:
      return 'Personal';
    case UserRole.passenger:
      return 'Pasajero';
  }
}

Color _roleColor(UserRole r) {
  switch (r) {
    case UserRole.admin:
      return AppColors.chipRed;
    case UserRole.staff:
      return AppColors.cyan;
    case UserRole.passenger:
      return AppColors.gray;
  }
}

/// Resultado del diálogo: contiene los datos y la contraseña (solo en creación).
class UserFormResult {
  final String displayName;
  final String email;
  final String password; // vacío en modo edición
  final UserRole role;
  final bool isActive;

  const UserFormResult({
    required this.displayName,
    required this.email,
    required this.password,
    required this.role,
    required this.isActive,
  });
}

Future<UserFormResult?> showUserFormDialog(
  BuildContext context, {
  UserModel? user,
}) {
  return showDialog<UserFormResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UserFormDialog(user: user),
  );
}

class _UserFormDialog extends StatefulWidget {
  final UserModel? user;
  const _UserFormDialog({this.user});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  final _formKey = GlobalKey<FormState>();
  late UserRole _selectedRole;
  late bool _isActive;
  var _obscurePass = true;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameCtrl = TextEditingController(text: u?.displayName ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _passCtrl = TextEditingController();
    _selectedRole = u?.role ?? UserRole.passenger;
    _isActive = u?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      UserFormResult(
        displayName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: _selectedRole,
        isActive: _isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Row(
        children: [
          Icon(
            _isEdit ? Icons.edit : Icons.person_add,
            color: AppColors.cyan,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _isEdit ? 'EDITAR USUARIO' : 'NUEVO USUARIO',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.gray),
                ),
                style: const TextStyle(color: AppColors.white),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                enabled: !_isEdit,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.gray),
                  helperText: _isEdit ? 'El correo no se puede modificar' : null,
                  helperStyle: const TextStyle(color: AppColors.gray, fontSize: 11),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: _isEdit ? AppColors.gray : AppColors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  if (!v.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (!_isEdit) ...[
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gray),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.gray,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.white),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.shield_outlined, color: AppColors.gray),
                ),
                dropdownColor: AppColors.card,
                style: const TextStyle(color: AppColors.white),
                items: UserRole.values.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _roleColor(r),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_roleLabel(r)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedRole = v);
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isActive ? Icons.check_circle_outline : Icons.block,
                          color: _isActive ? AppColors.chipGreen : AppColors.chipRed,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text('Usuario activo', style: TextStyle(color: AppColors.white)),
                      ],
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _roleColor(_selectedRole).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _roleColor(_selectedRole).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: _roleColor(_selectedRole), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _selectedRole == UserRole.admin
                          ? 'Acceso total al panel admin'
                          : _selectedRole == UserRole.staff
                          ? 'Acceso a operaciones'
                          : 'Solo vista de vuelos y reservas',
                      style: TextStyle(color: _roleColor(_selectedRole), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: AppColors.gray)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan),
          child: Text(
            _isEdit ? 'ACTUALIZAR' : 'CREAR',
            style: const TextStyle(color: AppColors.black),
          ),
        ),
      ],
    );
  }
}
