import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../models/flight_model.dart';
import 'status_chip.dart';

class FlightCard extends StatelessWidget {
  final FlightModel flight;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetail;
  final bool compact;
  final EdgeInsetsGeometry? margin;

  const FlightCard({
    super.key,
    required this.flight,
    this.onTap,
    this.onViewDetail,
    this.compact = false,
    this.margin,
  });

  Color get _leftBorderColor => StatusChip.colorForStatus(flight.status.value);
  String get _statusLabel => StatusChip.labelForStatus(flight.status.value);

  String get _duration {
    final diff = flight.arrivalTime.difference(flight.departureTime);
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  String get _formattedTime => DateFormat('HH:mm').format(flight.departureTime);
  String get _formattedArrival =>
      DateFormat('HH:mm').format(flight.arrivalTime);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          // Fondo más claro para que se vea el contenido
          color: const Color(0xFF1E2040),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _leftBorderColor.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _leftBorderColor.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Barra lateral de color según estado
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _leftBorderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 10),
                      _buildRoute(),
                      const SizedBox(height: 8),
                      _buildTimes(),
                      if (!compact) ...[
                        const SizedBox(height: 8),
                        _buildFooter(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          flight.flightNumber,
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.cyan,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          flight.airlineName,
          style: const TextStyle(fontSize: 12, color: AppColors.gray),
        ),
        const Spacer(),
        StatusChip(label: _statusLabel, color: _leftBorderColor),
      ],
    );
  }

  Widget _buildRoute() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flight.originCode,
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            Text(
              flight.originName,
              style: const TextStyle(fontSize: 10, color: AppColors.gray),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              const Icon(Icons.flight, size: 20, color: AppColors.cyan),
              const SizedBox(height: 2),
              Text(
                _duration,
                style: const TextStyle(fontSize: 10, color: AppColors.gray),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              flight.destinationCode,
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            Text(
              flight.destinationName,
              style: const TextStyle(fontSize: 10, color: AppColors.gray),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimes() {
    return Row(
      children: [
        const Icon(Icons.schedule, size: 13, color: AppColors.gray),
        const SizedBox(width: 4),
        Text(
          '$_formattedTime  →  $_formattedArrival',
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        const Icon(
          Icons.meeting_room_outlined,
          size: 13,
          color: AppColors.gray,
        ),
        const SizedBox(width: 4),
        Text(
          flight.gateName.isNotEmpty
              ? 'Puerta ${flight.gateName}'
              : 'Sin puerta',
          style: const TextStyle(fontSize: 12, color: AppColors.gray),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.event_seat_outlined, size: 13, color: AppColors.gray),
        const SizedBox(width: 4),
        Text(
          '${flight.availableSeats}/${flight.totalSeats} asientos',
          style: TextStyle(
            fontSize: 12,
            color: flight.availableSeats > 0
                ? AppColors.chipGreen
                : AppColors.chipRed,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          '\$${flight.basePrice.toStringAsFixed(0)}',
          style: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.chipGreen,
          ),
        ),
      ],
    );
  }
}

class DashPathWidget extends StatelessWidget {
  const DashPathWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 2,
          child: Row(
            children: List.generate(
              (constraints.maxWidth / 6).floor().clamp(1, 100),
              (i) => Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Container(
                  width: 3,
                  height: 1.5,
                  color: AppColors.gray.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
