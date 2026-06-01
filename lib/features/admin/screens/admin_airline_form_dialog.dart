import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/airline_model.dart';

Future<void> showAirlineFormDialog(
  BuildContext context, {
  AirlineModel? airline,
}) async {
  final isEditing = airline != null;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: airline?.name ?? '');
  final iataController = TextEditingController(text: airline?.iataCode ?? '');
  final countryController = TextEditingController(text: airline?.country ?? '');
  final iataFocus = FocusNode();
  final countryFocus = FocusNode();
  var isActive = airline?.isActive ?? true;
  var saving = false;

  await showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(
              isEditing ? 'EDITAR AEROLÍNEA' : 'NUEVA AEROLÍNEA',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ej: Aeroméxico',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      onFieldSubmitted: (_) => iataFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: iataController,
                      focusNode: iataFocus,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        labelText: 'Código IATA',
                        hintText: 'Ej: AM',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                      onFieldSubmitted: (_) => countryFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: countryController,
                      focusNode: countryFocus,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(color: AppColors.white),
                      decoration: const InputDecoration(
                        labelText: 'País',
                        hintText: 'Ej: México',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Activa',
                          style: TextStyle(color: AppColors.white, fontSize: 15),
                        ),
                        Switch(
                          value: isActive,
                          onChanged: (v) => setDialogState(() => isActive = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx),
                child: const Text('CANCELAR',
                  style: TextStyle(color: AppColors.gray),
                ),
              ),
              TextButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() => saving = true);

                        final provider = context.read<AdminProvider>();
                        final ok = isEditing
                            ? await provider.updateAirline(
                                airline.copyWith(
                                  name: nameController.text.trim(),
                                  iataCode: iataController.text.trim().toUpperCase(),
                                  country: countryController.text.trim(),
                                  isActive: isActive,
                                ),
                              )
                            : await provider.createAirline(
                                AirlineModel(
                                  id: '',
                                  name: nameController.text.trim(),
                                  iataCode: iataController.text.trim().toUpperCase(),
                                  country: countryController.text.trim(),
                                  isActive: isActive,
                                ),
                              );

                        if (ctx.mounted) {
                          if (ok) {
                            Navigator.pop(ctx);
                          } else {
                            setDialogState(() => saving = false);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Error al guardar aerolínea'),
                              ),
                            );
                          }
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.cyan,
                        ),
                      )
                    : Text(
                        isEditing ? 'ACTUALIZAR' : 'GUARDAR',
                        style: const TextStyle(color: AppColors.cyan),
                      ),
              ),
            ],
          );
        },
      );
    },
  );

  nameController.dispose();
  iataController.dispose();
  countryController.dispose();
}
