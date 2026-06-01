import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/passenger_model.dart';

Future<void> showPassengerFormDialog(
  BuildContext context, {
  PassengerModel? passenger,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _PassengerFormDialog(passenger: passenger),
  );
}

class _PassengerFormDialog extends StatefulWidget {
  final PassengerModel? passenger;
  const _PassengerFormDialog({this.passenger});

  @override
  State<_PassengerFormDialog> createState() => _PassengerFormDialogState();
}

class _PassengerFormDialogState extends State<_PassengerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passportCtrl;
  late final TextEditingController _ffnCtrl;
  bool _isActive = true;
  bool _saving = false;

  bool get _isEditing => widget.passenger != null;

  @override
  void initState() {
    super.initState();
    final p = widget.passenger;
    _firstNameCtrl = TextEditingController(text: p?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: p?.lastName ?? '');
    _emailCtrl = TextEditingController(text: p?.email ?? '');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '');
    _passportCtrl = TextEditingController(text: p?.passportNumber ?? '');
    _ffnCtrl = TextEditingController(text: p?.frequentFlyerNumber ?? '');
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passportCtrl.dispose();
    _ffnCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<AdminProvider>();
    final now = DateTime.now();
    final model = PassengerModel(
      id: widget.passenger?.id ?? '',
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      passportNumber: _passportCtrl.text.trim(),
      frequentFlyerNumber: _ffnCtrl.text.trim().isEmpty ? null : _ffnCtrl.text.trim(),
      isActive: _isActive,
      createdAt: widget.passenger?.createdAt ?? now,
    );

    bool ok;
    if (_isEditing) {
      ok = await provider.updatePassenger(model);
    } else {
      ok = await provider.createPassenger(model);
    }

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? (_isEditing ? 'Pasajero actualizado' : 'Pasajero creado') : 'Error al guardar'),
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
            _isEditing ? 'EDITAR PASAJERO' : 'NUEVO PASAJERO',
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
              const SizedBox(height: 12),
              _buildField('Teléfono', _phoneCtrl, 'Ingrese el teléfono', keyboardType: TextInputType.phone, required: false),
              const SizedBox(height: 12),
              _buildField('Pasaporte', _passportCtrl, 'Ingrese el pasaporte'),
              const SizedBox(height: 12),
              _buildField('Viajero Frecuente', _ffnCtrl, 'Opcional', required: false),
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
