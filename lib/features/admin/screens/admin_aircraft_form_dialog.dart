import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/aircraft_model.dart';
import '../../../shared/models/result_state.dart';

Future<void> showAircraftFormDialog(
  BuildContext context, {
  AircraftModel? aircraft,
}) {
  final isEditing = aircraft != null;
  final formKey = GlobalKey<FormState>();
  final modelCtrl = TextEditingController(text: aircraft?.model ?? '');
  final registrationCtrl =
      TextEditingController(text: aircraft?.registration ?? '');
  final airlineIdCtrl =
      TextEditingController(text: aircraft?.airlineId ?? '');
  final totalSeatsCtrl = TextEditingController(
      text: aircraft?.totalSeats.toString() ?? '');
  final firstClassSeatsCtrl = TextEditingController(
      text: aircraft?.firstClassSeats.toString() ?? '0');
  final businessSeatsCtrl = TextEditingController(
      text: aircraft?.businessSeats.toString() ?? '0');
  final economySeatsCtrl = TextEditingController(
      text: aircraft?.economySeats.toString() ?? '0');
  var selectedStatus = aircraft?.status ?? AircraftStatus.active;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text(
          isEditing ? 'EDITAR AERONAVE' : 'NUEVA AERONAVE',
          style: GoogleFonts.rajdhani(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField('Modelo', modelCtrl,
                    required: true, hint: 'Ej: Boeing 737-800'),
                const SizedBox(height: 14),
                _buildField('Matrícula', registrationCtrl,
                    required: true, hint: 'Ej: XA-ABC'),
                const SizedBox(height: 14),
                _buildField('Aerolínea ID', airlineIdCtrl,
                    required: true, hint: 'ID de la aerolínea'),
                const SizedBox(height: 14),
                _buildField('Total Asientos', totalSeatsCtrl,
                    required: true, numeric: true),
                const SizedBox(height: 14),
                _buildField('Asientos Primera Clase', firstClassSeatsCtrl,
                    numeric: true),
                const SizedBox(height: 14),
                _buildField('Asientos Business', businessSeatsCtrl,
                    numeric: true),
                const SizedBox(height: 14),
                _buildField('Asientos Económicos', economySeatsCtrl,
                    numeric: true),
                const SizedBox(height: 14),
                  DropdownButtonFormField<AircraftStatus>(
                    initialValue: selectedStatus,
                  dropdownColor: AppColors.card,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    labelStyle: const TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide:
                          const BorderSide(color: AppColors.cyan, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.white),
                  icon:
                      const Icon(Icons.expand_more, color: AppColors.cyan),
                  items: AircraftStatus.values.map((s) {
                    String label;
                    switch (s) {
                      case AircraftStatus.active:
                        label = 'Activa';
                      case AircraftStatus.maintenance:
                        label = 'Mantenimiento';
                      case AircraftStatus.retired:
                        label = 'Retirada';
                    }
                    return DropdownMenuItem(
                      value: s,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) selectedStatus = v;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR',
                style: TextStyle(color: AppColors.gray)),
          ),
          Consumer<AdminProvider>(
            builder: (context, provider, _) {
              final saving = provider.aircraftsState is Loading<List<AircraftModel>>;
              return TextButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        final data = AircraftModel(
                          id: aircraft?.id ?? '',
                          model: modelCtrl.text.trim(),
                          registration: registrationCtrl.text.trim(),
                          airlineId: airlineIdCtrl.text.trim(),
                          totalSeats: int.tryParse(totalSeatsCtrl.text) ?? 0,
                          firstClassSeats:
                              int.tryParse(firstClassSeatsCtrl.text) ?? 0,
                          businessSeats:
                              int.tryParse(businessSeatsCtrl.text) ?? 0,
                          economySeats:
                              int.tryParse(economySeatsCtrl.text) ?? 0,
                          status: selectedStatus,
                        );

                        bool success;
                        if (isEditing) {
                          success = await provider.updateAircraft(data);
                        } else {
                          success = await provider.createAircraft(data);
                        }

                        if (success && ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      },
                child: Text(
                  isEditing ? 'ACTUALIZAR' : 'GUARDAR',
                  style: TextStyle(
                    color: saving ? AppColors.gray : AppColors.cyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

Widget _buildField(
  String label,
  TextEditingController controller, {
  bool required = false,
  bool numeric = false,
  String? hint,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: AppColors.white),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.gray),
      labelStyle: const TextStyle(color: AppColors.gray),
    ),
    validator: (v) {
      if (required && (v == null || v.trim().isEmpty)) {
        return '$label es requerido';
      }
      if (numeric && v != null && v.isNotEmpty) {
        if (int.tryParse(v) == null) return 'Ingrese un número válido';
      }
      return null;
    },
  );
}
