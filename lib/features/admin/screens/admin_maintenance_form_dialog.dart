import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/maintenance_log_model.dart';

String _typeLabel(MaintenanceType t) {
  switch (t) {
    case MaintenanceType.routine:
      return 'Rutina';
    case MaintenanceType.repair:
      return 'Reparaci\u00F3n';
    case MaintenanceType.inspection:
      return 'Inspecci\u00F3n';
    case MaintenanceType.emergency:
      return 'Emergencia';
  }
}

String _statusLabel(MaintenanceStatus s) {
  switch (s) {
    case MaintenanceStatus.scheduled:
      return 'Programado';
    case MaintenanceStatus.inProgress:
      return 'En Progreso';
    case MaintenanceStatus.completed:
      return 'Completado';
    case MaintenanceStatus.deferred:
      return 'Diferido';
  }
}

Future<MaintenanceLogModel?> showMaintenanceFormDialog(
  BuildContext context, {
  MaintenanceLogModel? log,
}) async {
  final isEdit = log != null;
  final formKey = GlobalKey<FormState>();

  final aircraftIdCtrl = TextEditingController(text: log?.aircraftId ?? '');
  final aircraftRegCtrl = TextEditingController(
    text: log?.aircraftRegistration ?? '',
  );
  final descCtrl = TextEditingController(text: log?.description ?? '');
  final performedByIdCtrl = TextEditingController(
    text: log?.performedById ?? '',
  );

  var selectedType = log?.type ?? MaintenanceType.routine;
  var selectedStatus = log?.status ?? MaintenanceStatus.scheduled;
  var startDate = log?.startDate ?? DateTime.now();
  var endDate = log?.endDate;

  final dateFormat = DateFormat('dd/MM/yyyy');

  final result = await showDialog<MaintenanceLogModel>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(
              isEdit ? 'EDITAR MANTENIMIENTO' : 'NUEVO MANTENIMIENTO',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: aircraftIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ID de Aeronave',
                      ),
                      style: const TextStyle(color: AppColors.white),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: aircraftRegCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Matr\u00EDcula',
                      ),
                      style: const TextStyle(color: AppColors.white),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MaintenanceType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      dropdownColor: AppColors.card,
                      style: const TextStyle(color: AppColors.white),
                      items: MaintenanceType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(_typeLabel(t)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripci\u00F3n',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      style: const TextStyle(color: AppColors.white),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: performedByIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ID del Responsable',
                      ),
                      style: const TextStyle(color: AppColors.white),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final pickerContext = context;
                        final picked = await showDatePicker(
                          context: pickerContext,
                          initialDate: startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null && pickerContext.mounted) {
                          setDialogState(() => startDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de Inicio',
                        ),
                        child: Text(
                          dateFormat.format(startDate),
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final pickerContext = context;
                        final picked = await showDatePicker(
                          context: pickerContext,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null && pickerContext.mounted) {
                          setDialogState(() => endDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de Fin (opcional)',
                        ),
                        child: Text(
                          endDate != null ? dateFormat.format(endDate!) : '--',
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MaintenanceStatus>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      dropdownColor: AppColors.card,
                      style: const TextStyle(color: AppColors.white),
                      items: MaintenanceStatus.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(_statusLabel(s)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedStatus = v);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCELAR',
                  style: TextStyle(color: AppColors.gray),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(
                    context,
                    MaintenanceLogModel(
                      id: log?.id ?? '',
                      aircraftId: aircraftIdCtrl.text.trim(),
                      aircraftRegistration: aircraftRegCtrl.text.trim(),
                      type: selectedType,
                      description: descCtrl.text.trim(),
                      performedById: performedByIdCtrl.text.trim(),
                      startDate: startDate,
                      endDate: endDate,
                      status: selectedStatus,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                ),
                child: Text(
                  isEdit ? 'ACTUALIZAR' : 'GUARDAR',
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  aircraftIdCtrl.dispose();
  aircraftRegCtrl.dispose();
  descCtrl.dispose();
  performedByIdCtrl.dispose();

  return result;
}
