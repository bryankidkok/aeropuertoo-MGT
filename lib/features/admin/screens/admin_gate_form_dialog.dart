import 'package:flutter/material.dart';
import '../../../shared/models/gate_model.dart';
import '../../../core/theme/app_theme.dart';

Future<GateModel?> showGateFormDialog(
  BuildContext context, {
  GateModel? gate,
}) {
  final nameController = TextEditingController(text: gate?.name ?? '');
  final terminalIdController = TextEditingController(text: gate?.terminalId ?? '');
  final terminalNameController = TextEditingController(text: gate?.terminalName ?? '');
  var selectedStatus = gate?.status ?? GateStatus.available;
  final formKey = GlobalKey<FormState>();

  return showDialog<GateModel>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(
              gate == null ? 'Nueva puerta' : 'Editar puerta',
              style: const TextStyle(color: AppColors.white),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: terminalIdController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'ID Terminal'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: terminalNameController,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Nombre Terminal'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<GateStatus>(
                      initialValue: selectedStatus,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: const [
                        DropdownMenuItem(value: GateStatus.available, child: Text('Disponible')),
                        DropdownMenuItem(value: GateStatus.occupied, child: Text('Ocupada')),
                        DropdownMenuItem(value: GateStatus.maintenance, child: Text('Mantenimiento')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedStatus = v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCELAR', style: TextStyle(color: AppColors.gray)),
              ),
              TextButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final model = GateModel(
                    id: gate?.id ?? '',
                    name: nameController.text.trim(),
                    terminalId: terminalIdController.text.trim(),
                    terminalName: terminalNameController.text.trim(),
                    status: selectedStatus,
                    currentFlightId: gate?.currentFlightId,
                    currentFlightNumber: gate?.currentFlightNumber,
                  );
                  Navigator.pop(ctx, model);
                },
                child: Text(
                  gate == null ? 'GUARDAR' : 'ACTUALIZAR',
                  style: const TextStyle(color: AppColors.cyan),
                ),
              ),
            ],
          );
        },
      );
    },
  ).whenComplete(() {
    nameController.dispose();
    terminalIdController.dispose();
    terminalNameController.dispose();
  });
}
