import '../../core/utils/date_formatters.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../models/booking_model.dart';
import '../models/flight_model.dart';

class BoardingPassWidget extends StatelessWidget {
  final BookingModel booking;
  final FlightModel flight;

  const BoardingPassWidget({
    super.key,
    required this.booking,
    required this.flight,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormatters.fullDate(flight.departureTime);
    final timeStr = DateFormat('HH:mm').format(flight.departureTime);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: const Border(top: BorderSide(color: AppColors.cyan, width: 2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowCyan,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'BOARDING PASS',
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        color: AppColors.gray,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.chipGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.chipGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'CHECK-IN',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.chipGreen,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  booking.passengerName,
                  style: GoogleFonts.rajdhani(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      flight.flightNumber,
                      style: GoogleFonts.rajdhani(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cyan,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    if (booking.seatNumber != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'ASIENTO',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: AppColors.gray,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.seatNumber!,
                            style: GoogleFonts.rajdhani(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.originCode,
                            style: GoogleFonts.rajdhani(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            flight.originName,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.gray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.flight,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            flight.destinationCode,
                            style: GoogleFonts.rajdhani(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            flight.destinationName,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.gray,
                            ),
                            textAlign: TextAlign.end,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildDottedDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('FECHA', dateStr),
                      const SizedBox(height: 10),
                      _infoRow('HORA', timeStr),
                      const SizedBox(height: 10),
                      _infoRow(
                        'PUERTA',
                        flight.gateName.isNotEmpty ? flight.gateName : '—',
                      ),
                      const SizedBox(height: 10),
                      _infoRow(
                        'GRUPO',
                        booking.seatNumber != null
                            ? _boardingGroup(booking.seatNumber!)
                            : '—',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (booking.bookingReference.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QrImageView(
                      data: booking.bookingReference,
                      version: QrVersions.auto,
                      size: 80,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildDottedDivider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.content_copy, size: 14, color: AppColors.cyan),
                const SizedBox(width: 6),
                Text(
                  'PNR: ${booking.bookingReference}',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cyan,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                _actionChip(Icons.save_outlined, 'GUARDAR'),
                const SizedBox(width: 8),
                _actionChip(Icons.share_outlined, 'COMPARTIR'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedDivider() {
    return Row(
      children: List.generate(
        60,
        (i) => Expanded(
          child: Container(
            height: 1,
            margin: EdgeInsets.only(right: i < 59 ? 3 : 0),
            color: i % 2 == 0 ? AppColors.cardBorder : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: AppColors.gray,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _actionChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.cyan),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _boardingGroup(String seat) {
    final num =
        int.tryParse(RegExp(r'\d+').firstMatch(seat)?.group(0) ?? '0') ?? 0;
    if (num <= 5) return 'GRUPO 1';
    if (num <= 15) return 'GRUPO 2';
    return 'GRUPO 3';
  }
}
