import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/booking_provider.dart';
import '../../../shared/providers/flight_provider.dart';
import '../../../shared/models/booking_model.dart';
import '../../../shared/models/flight_model.dart';
import '../../../shared/widgets/boarding_pass_widget.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<BookingProvider>().fetchBookingsByPassenger(userId);
    }
    context.read<FlightProvider>().fetchFlights();
  }

  List<BookingModel> get _checkinReady {
    final bp = context.read<BookingProvider>();
    return bp.bookings.where((b) => b.status == BookingStatus.confirmed).toList();
  }

  Future<void> _doCheckin(BookingModel booking) async {
    final bp = context.read<BookingProvider>();
    final success = await bp.updateBookingStatus(booking.id, BookingStatus.checkedIn);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in realizado con éxito'),
          backgroundColor: AppColors.chipGreen,
        ),
      );
      _loadData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bp.errorMessage ?? 'Error al hacer check-in')),
      );
    }
  }

  FlightModel? _findFlight(String flightId) {
    return context.read<FlightProvider>().flights.where((f) => f.id == flightId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();
    final ready = _checkinReady;
    final checkedIn = context.read<BookingProvider>().bookings
        .where((b) => b.status == BookingStatus.checkedIn)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Check-in',
          style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
        ),
      ),
      body: bp.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.cyan))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ready.isNotEmpty) ...[
                    Text(
                      'PENDIENTES DE CHECK-IN',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...ready.map((booking) => _buildCheckinCard(booking)),
                  ],
                  if (checkedIn.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'TARJETAS DE EMBARQUE',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.chipGreen,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...checkedIn.map((booking) {
                      final flight = _findFlight(booking.flightId);
                      if (flight == null) return const SizedBox.shrink();
                      return BoardingPassWidget(booking: booking, flight: flight);
                    }),
                  ],
                  if (ready.isEmpty && checkedIn.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline, size: 64, color: AppColors.cardBorder),
                            const SizedBox(height: 16),
                            Text(
                              'Sin reservas para check-in',
                              style: GoogleFonts.rajdhani(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildCheckinCard(BookingModel booking) {
    final flight = _findFlight(booking.flightId);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.flightNumber,
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(height: 4),
                if (flight != null)
                  Text(
                    '${flight.originCode} → ${flight.destinationCode}',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray),
                  ),
                const SizedBox(height: 4),
                Text(
                  booking.passengerName,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () => _doCheckin(booking),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.chipGreen,
                foregroundColor: AppColors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              child: const Text('CHECK-IN'),
            ),
          ),
        ],
      ),
    );
  }
}
