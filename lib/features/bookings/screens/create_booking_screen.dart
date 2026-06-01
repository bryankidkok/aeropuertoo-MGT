import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_routes.dart';
import '../../../shared/providers/booking_provider.dart';
import '../../../shared/providers/flight_provider.dart';
import '../../../shared/models/flight_model.dart';
import '../../../shared/models/booking_model.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/seat_map_widget.dart';

class CreateBookingScreen extends StatefulWidget {
  final String flightId;

  const CreateBookingScreen({super.key, required this.flightId});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  int _currentStep = 0;

  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedSeat;
  String _paymentMethod = 'card';
  bool _saving = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null) {
      final parts = user!.displayName!.split(' ');
      _nameCtrl.text = parts.first;
      if (parts.length > 1) _lastNameCtrl.text = parts.sublist(1).join(' ');
    }
    if (user?.email != null) _emailCtrl.text = user!.email!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlightProvider>().fetchFlightById(widget.flightId);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passportCtrl.dispose();
    super.dispose();
  }

  FlightModel? get _flight {
    final fp = context.read<FlightProvider>();
    return fp.flights.where((f) => f.id == widget.flightId).firstOrNull ?? fp.selectedFlight;
  }

  double get _subtotal => _flight?.basePrice ?? 0;
  double get _taxes => _subtotal * 0.16;
  double get _total => _subtotal + _taxes;

  void _nextStep() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) return;
    if (_currentStep == 1 && _selectedSeat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un asiento')),
      );
      return;
    }
    if (_currentStep < 2) setState(() => _currentStep++);
  }

  Future<void> _confirmBooking() async {
    final flight = _flight;
    if (flight == null) return;

    setState(() => _saving = true);

    try {
      final bookingRef = 'AER-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final passengerName = '${_nameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}';

      final booking = BookingModel(
        id: '',
        flightId: flight.id,
        flightNumber: flight.flightNumber,
        passengerId: userId,
        passengerName: passengerName,
        bookingReference: bookingRef,
        totalAmount: _total,
        paymentMethod: _paymentMethod,
        paymentStatus: 'paid',
        seatNumber: _selectedSeat,
        createdAt: DateTime.now(),
      );

      final bp = context.read<BookingProvider>();
      final success = await bp.createBooking(booking);

      if (success) {
        setState(() => _success = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(bp.errorMessage ?? 'Error al crear reserva')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al procesar la reserva')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flight = _flight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nueva Reserva',
          style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: flight == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.cyan))
          : _success
              ? _buildSuccess(context, flight)
              : Column(
                  children: [
                    _buildStepper(context),
                    Expanded(
                      child: IndexedStack(
                        index: _currentStep,
                        children: [
                          _buildPassengerForm(context),
                          _buildSeatSelection(context, flight),
                          _buildConfirmation(context, flight),
                        ],
                      ),
                    ),
                    if (!_success)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          border: Border(top: BorderSide(color: AppColors.cardBorder)),
                        ),
                        child: SafeArea(
                          child: _currentStep < 2
                              ? GradientButton(
                                  label: _currentStep == 0
                                      ? 'CONTINUAR A ASIENTO'
                                      : 'CONTINUAR A PAGO',
                                  onPressed: _nextStep,
                                )
                              : GradientButton(
                                  label: _saving ? 'PROCESANDO...' : 'CONFIRMAR RESERVA',
                                  isLoading: _saving,
                                  onPressed: _saving ? null : _confirmBooking,
                                ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildStepper(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = _currentStep == index;
          final isDone = _currentStep > index;
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone ? AppColors.cyan : AppColors.inputBorder,
                    ),
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.cyan
                        : isActive
                            ? AppColors.cyan.withValues(alpha: 0.2)
                            : AppColors.inputFill,
                    border: Border.all(
                      color: isActive || isDone ? AppColors.cyan : AppColors.inputBorder,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check, size: 16, color: AppColors.black)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isActive ? AppColors.cyan : AppColors.gray,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPassengerForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DATOS DEL PASAJERO',
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.cyan,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline, size: 18, color: AppColors.gray),
                    ),
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                    validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Requerido',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: Icon(Icons.person_outline, size: 18, color: AppColors.gray),
                    ),
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                    validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Requerido',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, size: 18, color: AppColors.gray),
              ),
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                if (!v.contains('@')) return 'Email inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone_outlined, size: 18, color: AppColors.gray),
              ),
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Requerido',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passportCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Número de Pasaporte',
                prefixIcon: Icon(Icons.badge_outlined, size: 18, color: AppColors.gray),
              ),
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Requerido',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatSelection(BuildContext context, FlightModel flight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SELECCIONA TU ASIENTO',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyan,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              if (_selectedSeat != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.cyan),
                  ),
                  child: Text(
                    _selectedSeat!,
                    style: const TextStyle(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${flight.flightNumber} · ${flight.originCode} → ${flight.destinationCode}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray),
          ),
          const SizedBox(height: 16),
          SeatMapWidget(
            selectedSeat: _selectedSeat,
            onSeatSelected: (seat) => setState(() => _selectedSeat = seat),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation(BuildContext context, FlightModel flight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONFIRMACIÓN',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.cyan,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          _summaryRow('Vuelo', flight.flightNumber),
          _summaryRow('Ruta', '${flight.originCode} → ${flight.destinationCode}'),
          _summaryRow('Pasajero', '${_nameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'),
          _summaryRow('Asiento', _selectedSeat ?? '—'),
          _summaryRow('Email', _emailCtrl.text.trim()),
          const Divider(height: 24, color: AppColors.cardBorder),
          _summaryRow('Precio Base', '\$${_subtotal.toStringAsFixed(2)}'),
          _summaryRow('Impuestos (16%)', '\$${_taxes.toStringAsFixed(2)}'),
          Row(
            children: [
              Text(
                'TOTAL',
                style: GoogleFonts.rajdhani(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: GoogleFonts.rajdhani(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.chipGreen,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.cardBorder),
          Text(
            'MÉTODO DE PAGO',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray),
          ),
          const SizedBox(height: 8),
          _paymentOption('card', Icons.credit_card, 'Tarjeta de Crédito/Débito'),
          _paymentOption('transfer', Icons.account_balance, 'Transferencia Bancaria'),
          _paymentOption('cash', Icons.money, 'Efectivo (Solo mostrador)'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption(String value, IconData icon, String label) {
    final isSelected = _paymentMethod == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cyan.withValues(alpha: 0.1) : AppColors.inputFill,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.cyan : AppColors.inputBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.cyan : AppColors.gray),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? AppColors.white : AppColors.gray,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle, size: 18, color: AppColors.cyan),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, FlightModel flight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: AppColors.chipGreen),
            const SizedBox(height: 24),
            Text(
              'RESERVA CONFIRMADA',
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${flight.flightNumber} · ${flight.originCode} → ${flight.destinationCode}',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray),
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'MIS RESERVAS',
              onPressed: () => context.go(AppRoutes.bookings),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text(
                'Volver al inicio',
                style: TextStyle(color: AppColors.cyan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
