import '../../../core/utils/date_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/flight_provider.dart';
import '../../../shared/models/flight_model.dart';
import '../../../shared/widgets/status_chip.dart';

class FlightDetailScreen extends StatefulWidget {
  final String flightId;

  const FlightDetailScreen({super.key, required this.flightId});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlightProvider>().fetchFlightById(widget.flightId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlightProvider>();
    final flight = provider.selectedFlight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          flight?.flightNumber ?? 'Detalle de Vuelo',
          style: GoogleFonts.rajdhani(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: flight == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.cyan),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildRouteMap(context, flight),
                  _buildInfoCard(context, flight),
                  _buildDetailsGrid(context, flight),
                  _buildFlightsVertical(context, flight),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: flight != null && flight.availableSeats > 0
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: SafeArea(
                child: Ink(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.cyan, AppColors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => context.push('/bookings/create/${flight.id}'),
                    child: const Center(
                      child: Text(
                        'RESERVAR VUELO',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildRouteMap(BuildContext context, FlightModel flight) {
    final statusColor = StatusChip.colorForStatus(flight.status.value);
    final dateStr = DateFormatters.fullDate(flight.departureTime);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            dateStr.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.gray,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
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
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(flight.departureTime),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.gray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flight.originName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.gray,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.cyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 30),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1500),
                          builder: (context, value, _) {
                            return Transform.translate(
                              offset: Offset(0, -8 * value.sin()),
                              child: SvgPicture.asset(
                                'assets/images/airplane_silhouette.svg',
                                width: 24,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.cyan,
                                  BlendMode.srcIn,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 30),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.cyan, statusColor],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _calculateDuration(flight),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
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
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(flight.arrivalTime),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.gray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flight.destinationName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.gray,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StatusChip(
            label: StatusChip.labelForStatus(flight.status.value),
            color: statusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, FlightModel flight) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  'Aerolínea',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.gray),
                ),
                const SizedBox(height: 4),
                Text(
                  flight.airlineName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aeronave',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.gray),
                ),
                const SizedBox(height: 4),
                Text(
                  flight.aircraftId.isNotEmpty ? flight.aircraftId : '—',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context, FlightModel flight) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _detailRow(
            Icons.meeting_room_outlined,
            'Puerta de Embarque',
            flight.gateName.isNotEmpty ? flight.gateName : 'Por asignar',
          ),
          const Divider(height: 24, color: AppColors.cardBorder),
          _detailRow(
            Icons.event_seat_outlined,
            'Asientos Disponibles',
            '${flight.availableSeats}/${flight.totalSeats}',
          ),
          const Divider(height: 24, color: AppColors.cardBorder),
          _detailRow(
            Icons.airplane_ticket_outlined,
            'Precio Base',
            '\$${flight.basePrice.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gray),
        const SizedBox(width: 12),
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
    );
  }

  Widget _buildFlightsVertical(BuildContext context, FlightModel flight) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INFORMACIÓN DEL VUELO',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.cyan,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow('Origen', '${flight.originCode} - ${flight.originName}'),
          _infoRow(
            'Destino',
            '${flight.destinationCode} - ${flight.destinationName}',
          ),
          _infoRow(
            'Salida',
            DateFormat('dd/MM/yyyy HH:mm').format(flight.departureTime),
          ),
          _infoRow(
            'Llegada',
            DateFormat('dd/MM/yyyy HH:mm').format(flight.arrivalTime),
          ),
          _infoRow('Duración', _calculateDuration(flight)),
          _infoRow('Estado', StatusChip.labelForStatus(flight.status.value)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.gray),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration(FlightModel flight) {
    final diff = flight.arrivalTime.difference(flight.departureTime);
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }
}

extension _DoubleX on double {
  double sin() => switch (this) {
    _ when this < 0.25 => this * 4,
    _ when this < 0.5 => (0.5 - this) * 4,
    _ when this < 0.75 => (this - 0.5) * 4,
    _ => (1 - this) * 4,
  };
}
