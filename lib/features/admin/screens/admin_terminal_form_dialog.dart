import 'package:flutter/material.dart';
import '../../../shared/models/terminal_model.dart';
import '../../../core/theme/app_theme.dart';

Future<TerminalModel?> showTerminalFormDialog(
  BuildContext context, {
  TerminalModel? terminal,
}) {
  final nameController = TextEditingController(text: terminal?.name ?? '');
  final codeController = TextEditingController(text: terminal?.code ?? '');
  final gatesCountController = TextEditingController(
    text: terminal?.gatesCount.toString() ?? '0',
  );
  final formKey = GlobalKey<FormState>();

  return showDialog<TerminalModel>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          terminal == null ? 'Nueva terminal' : 'Editar terminal',
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
                  controller: codeController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(labelText: 'Código'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: gatesCountController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(labelText: 'Cantidad de puertas'),
                  keyboardType: TextInputType.number,
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
              final model = TerminalModel(
                id: terminal?.id ?? '',
                name: nameController.text.trim(),
                code: codeController.text.trim().toUpperCase(),
                gatesCount: int.tryParse(gatesCountController.text.trim()) ?? 0,
              );
              Navigator.pop(ctx, model);
            },
            child: Text(
              terminal == null ? 'GUARDAR' : 'ACTUALIZAR',
              style: const TextStyle(color: AppColors.cyan),
            ),
          ),
        ],
      );
    },
  ).whenComplete(() {
    nameController.dispose();
    codeController.dispose();
    gatesCountController.dispose();
  });
}
