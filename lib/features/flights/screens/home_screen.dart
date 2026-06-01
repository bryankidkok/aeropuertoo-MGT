import '../../../core/utils/date_formatters.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_routes.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/flight_provider.dart';
import '../../../shared/providers/notifications_provider.dart';
import '../../../shared/widgets/flight_card.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureListeners();
    });
  }

  void _ensureListeners() {
    final fp = context.read<FlightProvider>();
    if (!fp.isListening || fp.isFiltered) {
      fp.startListening();
    }
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user != null) {
      context.read<NotificationsProvider>().startListening(user.uid);
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.cyan,
              onPrimary: AppColors.black,
              surface: AppColors.surface,
              onSurface: AppColors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null && mounted) {
      setState(() => _selectedDate = date);
    }
  }

  void _searchFlights() {
    if (!mounted) return;
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();
    context.read<FlightProvider>().searchFlights(
      origin: origin,
      destination: destination,
      date: _selectedDate,
    );
    context.push(AppRoutes.flights);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final flightProvider = context.watch<FlightProvider>();
    final notificationsProvider = context.watch<NotificationsProvider>();
    final user = auth.user;
    final allFlights = flightProvider.flights;

    final now = DateTime.now();
    final todayFlights = allFlights
        .where(
          (f) =>
              f.departureTime.year == now.year &&
              f.departureTime.month == now.month &&
              f.departureTime.day == now.day,
        )
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'AEROPUERTO',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.cyan,
                letterSpacing: 2,
              ),
            ),
            Text(
              ' MGT',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.shield_outlined, color: AppColors.orange),
              tooltip: 'Panel Admin',
              onPressed: () => context.push(AppRoutes.admin),
            ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: AppColors.gray,
                onPressed: () => context.push(AppRoutes.notifications),
              ),
              if (notificationsProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.chipRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${notificationsProvider.unreadCount}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.profile),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.cardBorder,
              child: Text(
                (user?.displayName ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final fp = context.read<FlightProvider>();
          await fp.fetchFlights(force: true);
          fp.startListening();
        },
        color: AppColors.cyan,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Buscador ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildSearchHero(context)),

            // ── Vuelos de hoy (carrusel horizontal) ───────────────────
            if (todayFlights.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        'VUELOS DE HOY',
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormatters.monthDay(now),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    itemCount: todayFlights.length,
                    itemBuilder: (context, index) {
                      final flight = todayFlights[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 280,
                          child: FlightCard(
                            flight: flight,
                            compact: true,
                            margin: EdgeInsets.zero,
                            onTap: () => context.push(
                              '${AppRoutes.flights}/${flight.id}',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
            ],

            // ── Todos los vuelos (lista vertical) ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'TODOS LOS VUELOS',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            if (flightProvider.isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.cyan),
                  ),
                ),
              )
            else if (flightProvider.errorMessage != null)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: AppColors.cardBorder,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          flightProvider.errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.gray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => context
                              .read<FlightProvider>()
                              .fetchFlights(force: true),
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.cyan,
                          ),
                          label: Text(
                            'Reintentar',
                            style: GoogleFonts.inter(color: AppColors.cyan),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (allFlights.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.flight,
                          size: 80,
                          color: AppColors.cardBorder,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay vuelos disponibles',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.gray,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () => context
                              .read<FlightProvider>()
                              .fetchFlights(force: true),
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.cyan,
                          ),
                          label: Text(
                            'Recargar',
                            style: GoogleFonts.inter(color: AppColors.cyan),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == allFlights.length) {
                    return const SizedBox(height: 24);
                  }
                  final flight = allFlights[index];
                  return FlightCard(
                    flight: flight,
                    onTap: () =>
                        context.push('${AppRoutes.flights}/${flight.id}'),
                    onViewDetail: () =>
                        context.push('${AppRoutes.flights}/${flight.id}'),
                  );
                }, childCount: allFlights.length + 1),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildSearchHero(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowCyan,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff, size: 18, color: AppColors.cyan),
              const SizedBox(width: 8),
              Text(
                'BUSCAR VUELOS',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cyan,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _originController,
                  decoration: const InputDecoration(
                    hintText: 'Origen',
                    prefixIcon: Icon(
                      Icons.flight_takeoff,
                      size: 18,
                      color: AppColors.gray,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    hintText: 'Destino',
                    prefixIcon: Icon(
                      Icons.flight_land,
                      size: 18,
                      color: AppColors.gray,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: _selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : 'Fecha',
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: AppColors.gray,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _searchFlights,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.cyan, AppColors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'BUSCAR',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
