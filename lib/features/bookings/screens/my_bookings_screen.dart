import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/booking_provider.dart';
import '../../../shared/models/booking_model.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        context.read<BookingProvider>().fetchBookingsByPassenger(userId);
      }
    });
  }

  List<BookingModel> _filteredBookings(List<BookingModel> all) {
    if (_filter == 'all') return all;
    switch (_filter) {
      case 'confirmed':
        return all.where((b) => b.status == BookingStatus.confirmed).toList();
      case 'checked_in':
        return all.where((b) => b.status == BookingStatus.checkedIn).toList();
      case 'cancelled':
        return all.where((b) => b.status == BookingStatus.cancelled).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();
    final filtered = _filteredBookings(bp.bookings);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Reservas',
          style: GoogleFonts.rajdhani(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.cyan),
            onPressed: () {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                context.read<BookingProvider>().fetchBookingsByPassenger(
                  userId,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: bp.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.cyan),
                  )
                : bp.errorMessage != null
                ? _buildError(context, bp.errorMessage!)
                : filtered.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    color: AppColors.cyan,
                    backgroundColor: AppColors.surface,
                    onRefresh: () async {
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      if (userId != null) {
                        await context
                            .read<BookingProvider>()
                            .fetchBookingsByPassenger(userId);
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _BookingCard(booking: filtered[index]),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('all', 'Todas'),
      ('confirmed', 'Confirmadas'),
      ('checked_in', 'Check-in'),
      ('cancelled', 'Canceladas'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _filter == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filter = f.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.cyan.withValues(alpha: 0.15)
                        : AppColors.inputFill,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.cyan
                          : AppColors.inputBorder,
                    ),
                  ),
                  child: Text(
                    f.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.cyan : AppColors.gray,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: AppColors.cardBorder,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin reservas',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _filter == 'all'
                  ? 'Aún no tienes reservas.\nBusca un vuelo para comenzar.'
                  : 'No hay reservas con ese filtro.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppColors.cardBorder),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.gray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  context.read<BookingProvider>().fetchBookingsByPassenger(
                    userId,
                  );
                }
              },
              icon: const Icon(Icons.refresh, color: AppColors.cyan),
              label: Text(
                'Reintentar',
                style: GoogleFonts.inter(color: AppColors.cyan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return AppColors.cyan;
      case BookingStatus.checkedIn:
        return AppColors.chipGreen;
      case BookingStatus.boarded:
        return AppColors.chipYellow;
      case BookingStatus.cancelled:
        return AppColors.chipRed;
      case BookingStatus.noShow:
        return AppColors.chipPurple;
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return 'Confirmada';
      case BookingStatus.checkedIn:
        return 'Check-in';
      case BookingStatus.boarded:
        return 'Abordó';
      case BookingStatus.cancelled:
        return 'Cancelada';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2040),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _statusColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Barra lateral de color
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        booking.flightNumber,
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cyan,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(label: _statusLabel, color: _statusColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.passengerName,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Reservado: ${DateFormat('dd/MM/yyyy HH:mm').format(booking.createdAt)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.gray),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  booking.bookingReference,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                if (booking.seatNumber != null)
                  Text(
                    'Asiento ${booking.seatNumber}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.chipGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '\$${booking.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.chipGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
