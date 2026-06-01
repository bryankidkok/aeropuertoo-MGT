import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/admin_provider.dart';
import '../../../shared/models/flight_model.dart';

Future<void> showFlightFormDialog(BuildContext context, {FlightModel? flight}) async {
  final provider = context.read<AdminProvider>();
  final formKey = GlobalKey<FormState>();

  final flightNumberCtrl = TextEditingController(text: flight?.flightNumber ?? '');
  final originCodeCtrl = TextEditingController(text: flight?.originCode ?? '');
  final originNameCtrl = TextEditingController(text: flight?.originName ?? '');
  final destinationCodeCtrl = TextEditingController(text: flight?.destinationCode ?? '');
  final destinationNameCtrl = TextEditingController(text: flight?.destinationName ?? '');
  final basePriceCtrl = TextEditingController(text: flight?.basePrice.toString() ?? '');
  final totalSeatsCtrl = TextEditingController(text: flight?.totalSeats.toString() ?? '');
  final availableSeatsCtrl = TextEditingController(text: flight?.availableSeats.toString() ?? '');
  final airlineIdCtrl = TextEditingController(text: flight?.airlineId ?? '');
  final airlineNameCtrl = TextEditingController(text: flight?.airlineName ?? '');
  final aircraftIdCtrl = TextEditingController(text: flight?.aircraftId ?? '');
  final gateIdCtrl = TextEditingController(text: flight?.gateId ?? '');
  final gateNameCtrl = TextEditingController(text: flight?.gateName ?? '');

  DateTime departureTime = flight?.departureTime ?? DateTime.now();
  DateTime arrivalTime = flight?.arrivalTime ?? DateTime.now().add(const Duration(hours: 2));
  FlightStatus status = flight?.status ?? FlightStatus.scheduled;

  final bool isEditing = flight != null;
  final dateFmt = DateFormat('dd/MM/yyyy');
  final timeFmt = DateFormat('HH:mm');

  Future<void> pickDateTime(DateTime initial, bool isDeparture) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.cyan,
            onPrimary: AppColors.black,
            surface: AppColors.surface,
            onSurface: AppColors.white,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.cyan,
            onPrimary: AppColors.black,
            surface: AppColors.surface,
            onSurface: AppColors.white,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (isDeparture) {
      departureTime = picked;
    } else {
      arrivalTime = picked;
    }
  }

  await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setInnerState) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Row(
          children: [
            Icon(isEditing ? Icons.edit : Icons.add_circle_outline, color: AppColors.cyan, size: 22),
            const SizedBox(width: 10),
            Text(
              isEditing ? 'EDITAR VUELO' : 'NUEVO VUELO',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Field(label: 'Número de Vuelo', controller: flightNumberCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _Field(label: 'Código Origen', controller: originCodeCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _Field(label: 'Nombre Origen', controller: originNameCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _Field(label: 'Código Destino', controller: destinationCodeCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _Field(label: 'Nombre Destino', controller: destinationNameCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateTimeField(
                          label: 'Salida',
                          value: departureTime,
                          fmt: '${dateFmt.format(departureTime)} ${timeFmt.format(departureTime)}',
                          onTap: () async {
                            await pickDateTime(departureTime, true);
                            setInnerState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateTimeField(
                          label: 'Llegada',
                          value: arrivalTime,
                          fmt: '${dateFmt.format(arrivalTime)} ${timeFmt.format(arrivalTime)}',
                          onTap: () async {
                            await pickDateTime(arrivalTime, false);
                            setInnerState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _Field(label: 'Precio Base', controller: basePriceCtrl, isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _Field(label: 'Asientos Totales', controller: totalSeatsCtrl, isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(child: _Field(label: 'Asientos Disp.', controller: availableSeatsCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _Field(label: 'ID Aerolínea', controller: airlineIdCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _Field(label: 'Nombre Aerolínea', controller: airlineNameCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _Field(label: 'ID Aeronave', controller: aircraftIdCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _Field(label: 'ID Puerta', controller: gateIdCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _Field(label: 'Nombre Puerta', controller: gateNameCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<FlightStatus>(
                    initialValue: status,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(),
                    ),
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.white),
                    items: FlightStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s.name.toUpperCase(),
                          style: const TextStyle(color: AppColors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setInnerState(() => status = v);
                      }
                    },
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR', style: TextStyle(color: AppColors.gray)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = FlightModel(
                id: flight?.id ?? '',
                flightNumber: flightNumberCtrl.text.trim(),
                originCode: originCodeCtrl.text.trim().toUpperCase(),
                originName: originNameCtrl.text.trim(),
                destinationCode: destinationCodeCtrl.text.trim().toUpperCase(),
                destinationName: destinationNameCtrl.text.trim(),
                departureTime: departureTime,
                arrivalTime: arrivalTime,
                basePrice: double.tryParse(basePriceCtrl.text.trim()) ?? 0,
                totalSeats: int.tryParse(totalSeatsCtrl.text.trim()) ?? 0,
                availableSeats: int.tryParse(availableSeatsCtrl.text.trim()) ?? 0,
                airlineId: airlineIdCtrl.text.trim(),
                airlineName: airlineNameCtrl.text.trim(),
                aircraftId: aircraftIdCtrl.text.trim(),
                gateId: gateIdCtrl.text.trim(),
                gateName: gateNameCtrl.text.trim(),
                status: status,
                createdAt: flight?.createdAt ?? DateTime.now(),
              );
              bool success;
              if (isEditing) {
                success = await provider.updateFlight(data);
              } else {
                success = await provider.createFlight(data);
              }
              if (!ctx.mounted) return;
              if (success) {
                Navigator.pop(ctx, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing ? 'Vuelo actualizado' : 'Vuelo creado'),
                    backgroundColor: AppColors.chipGreen,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al guardar el vuelo'),
                    backgroundColor: AppColors.chipRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan),
            child: Text(
              isEditing ? 'ACTUALIZAR' : 'GUARDAR',
              style: const TextStyle(color: AppColors.black),
            ),
          ),
        ],
      ),
    ),
  );

  flightNumberCtrl.dispose();
  originCodeCtrl.dispose();
  originNameCtrl.dispose();
  destinationCodeCtrl.dispose();
  destinationNameCtrl.dispose();
  basePriceCtrl.dispose();
  totalSeatsCtrl.dispose();
  availableSeatsCtrl.dispose();
  airlineIdCtrl.dispose();
  airlineNameCtrl.dispose();
  aircraftIdCtrl.dispose();
  gateIdCtrl.dispose();
  gateNameCtrl.dispose();
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isNumber;
  const _Field({required this.label, required this.controller, this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(labelText: label, filled: true, fillColor: AppColors.inputFill, border: const OutlineInputBorder()),
      validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime value;
  final String fmt;
  final VoidCallback onTap;
  const _DateTimeField({required this.label, required this.value, required this.fmt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.inputFill,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, color: AppColors.cyan, size: 18),
        ),
        child: Text(fmt, style: const TextStyle(color: AppColors.white, fontSize: 14)),
      ),
    );
  }
}
