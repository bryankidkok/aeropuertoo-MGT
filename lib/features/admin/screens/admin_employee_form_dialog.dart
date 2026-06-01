import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/employee_model.dart';

Future<void> showEmployeeFormDialog(
  BuildContext context, {
  EmployeeModel? employee,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _EmployeeFormDialog(employee: employee),
  );
}

class _EmployeeFormDialog extends StatefulWidget {
  final EmployeeModel? employee;
  const _EmployeeFormDialog({this.employee});

  @override
  State<_EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<_EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _terminalCtrl;
  late String _role;
  bool _isAdmin = false;
  bool _isActive = true;
  bool _saving = false;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _firstNameCtrl = TextEditingController(text: e?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: e?.lastName ?? '');
    _emailCtrl = TextEditingController(text: e?.email ?? '');
    _terminalCtrl = TextEditingController(text: e?.assignedTerminalId ?? '');
    _role = e?.role ?? 'passenger';
    _isAdmin = _role == 'admin';
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _terminalCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<AdminProvider>();
    final now = DateTime.now();
    final model = EmployeeModel(
      id: widget.employee?.id ?? '',
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      role: _role,
      assignedTerminalId: _terminalCtrl.text.trim().isEmpty ? null : _terminalCtrl.text.trim(),
      isActive: _isActive,
      createdAt: widget.employee?.createdAt ?? now,
    );

    bool ok;
    if (_isEditing) {
      ok = await provider.updateEmployee(model);
    } else {
      ok = await provider.createEmployee(model);
    }

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? (_isEditing ? 'Empleado actualizado' : 'Empleado creado') : 'Error al guardar'),
          backgroundColor: ok ? AppColors.chipGreen : AppColors.chipRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Row(
        children: [
          Icon(_isEditing ? Icons.edit : Icons.person_add, color: AppColors.cyan, size: 22),
          const SizedBox(width: 10),
          Text(
            _isEditing ? 'EDITAR EMPLEADO' : 'NUEVO EMPLEADO',
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Nombre', _firstNameCtrl, 'Ingrese el nombre'),
              const SizedBox(height: 12),
              _buildField('Apellido', _lastNameCtrl, 'Ingrese el apellido'),
              const SizedBox(height: 12),
              _buildField('Email', _emailCtrl, 'Ingrese el email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                dropdownColor: AppColors.inputFill,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  DropdownMenuItem(value: 'passenger', child: Text('Passenger')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _role = v;
                      _isAdmin = v == 'admin';
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('¿Es administrador?', style: TextStyle(color: AppColors.white)),
                  const Spacer(),
                  Switch(
                    value: _isAdmin,
                    onChanged: (v) {
                      setState(() {
                        _isAdmin = v;
                        _role = v ? 'admin' : 'passenger';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildField('Terminal Asignada (ID)', _terminalCtrl, 'Opcional', required: false),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Activo', style: TextStyle(color: AppColors.white)),
                  const Spacer(),
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('CANCELAR', style: TextStyle(color: AppColors.gray)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cyan,
            foregroundColor: AppColors.black,
          ),
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
              : Text(_isEditing ? 'ACTUALIZAR' : 'GUARDAR'),
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) return '$label es requerido';
              if (label == 'Email') {
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(v.trim())) return 'Email inválido';
              }
              return null;
            }
          : null,
    );
  }
}
